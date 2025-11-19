import 'dart:async';
import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:rxdart/rxdart.dart';

import '../models/cached_ttl_etag_response.dart';
import '../models/cache_ttl_etag_state.dart';
import '../models/cache_ttl_etag_config.dart';

/// Repository pattern implementation for cached data access
///
/// This repository provides a reactive stream-based interface to cached data,
/// automatically handling encryption/decryption, TTL validation, and state updates.
///
/// Example:
/// ```dart
/// final userRepo = CachedTtlEtagRepository<User>(
///   config: CacheTtlEtagConfig<User>(
///     url: 'https://api.example.com/user/123',
///     fromJson: (json) => User.fromJson(json),
///     defaultTtl: Duration(minutes: 5),
///   ),
/// );
///
/// // Listen to state changes
/// userRepo.stream.listen((state) {
///   if (state.hasData) {
///     print('User: ${state.data!.name}');
///   }
/// });
///
/// // Fetch data
/// await userRepo.fetch();
///
/// // Dispose when done
/// userRepo.dispose();
/// ```
class CachedTtlEtagRepository<T> {
  final CacheTtlEtagConfig<T> config;

  late final String _cacheKey;
  late final BehaviorSubject<CacheTtlEtagState<T>> _stateController;
  StreamSubscription? _cacheSubscription;
  StreamSubscription? _updateSubscription;

  /// Create a new repository instance with configuration
  ///
  /// [config] - Configuration object containing all repository parameters
  CachedTtlEtagRepository({required this.config}) {
    _cacheKey = config.getCacheKey?.call(config.url, config.body) ??
        config.cache.generateCacheKey(config.url, config.body);
    _stateController = BehaviorSubject<CacheTtlEtagState<T>>.seeded(
      const CacheTtlEtagState(isLoading: true),
    );
    _initialize();
  }

  /// Stream of cache state updates
  ///
  /// Emits a new state whenever the cache is updated, including:
  /// - Data changes
  /// - Loading state changes
  /// - Error state changes
  /// - Stale/TTL status changes
  Stream<CacheTtlEtagState<T>> get stream => _stateController.stream;

  /// Current state snapshot
  CacheTtlEtagState<T> get state => _stateController.value;

  void _initialize() {
    // Watch for cache changes in the database
    _cacheSubscription = config.cache.isar.cachedTtlEtagResponses
        .watchLazy(fireImmediately: true)
        .asyncMap((_) => _loadCacheEntry())
        .listen(_updateState);

    // Watch for cache update events
    _updateSubscription = config.cache.updateStream.listen((_) {
      // State will be updated via _cacheSubscription
    });

    // Initial fetch
    if (config.autofetch == true) {
      fetch();
    }
  }

  Future<CachedTtlEtagResponse?> _loadCacheEntry() async {
    return await config.cache.isar.cachedTtlEtagResponses
        .filter()
        .urlEqualTo(_cacheKey)
        .findFirst();
  }

  void _updateState(CachedTtlEtagResponse? cached) {
    final currentState = _stateController.value;

    T? data;
    if (cached != null) {
      try {
        // Get data based on encryption status
        String? rawData;
        if (cached.isEncrypted) {
          if (config.cache.isEncryptionEnabled) {
            rawData = config.cache.getDataFromCache(cached);
          } else {
            // Can't decrypt without encryption enabled
            _stateController.add(currentState.copyWith(
              error:
                  Exception('Cache is encrypted but encryption is not enabled'),
              isLoading: false,
            ));
            return;
          }
        } else {
          rawData = cached.data;
        }

        if (rawData != null) {
          data = config.fromJson(jsonDecode(rawData));
        }
      } catch (e) {
        _stateController.add(currentState.copyWith(
          error: e,
          isLoading: false,
        ));
        return;
      }
    }

    _stateController.add(CacheTtlEtagState(
      data: data,
      isLoading: currentState.isLoading,
      isStale: cached?.isStale ?? false,
      error: currentState.error,
      timestamp: cached?.timestamp,
      ttlSeconds: cached?.ttlSeconds,
      etag: cached?.etag,
    ));
  }

  /// Fetch data from the network
  ///
  /// This method:
  /// 1. Sets loading state
  /// 2. Calls the cache service to fetch data
  /// 3. Updates state based on success or failure
  ///
  /// [forceRefresh] - If true, ignores cache and forces a network request
  ///
  /// Example:
  /// ```dart
  /// // Normal fetch (uses cache if valid)
  /// await repo.fetch();
  ///
  /// // Force refresh (bypasses cache)
  /// await repo.fetch(forceRefresh: true);
  /// ```
  Future<void> fetch({bool forceRefresh = false}) async {
    _stateController.add(_stateController.value.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      await config.cache.fetchReactive<T>(
        config: config,
        forceRefresh: forceRefresh,
      );

      _stateController.add(_stateController.value.copyWith(
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      _stateController.add(_stateController.value.copyWith(
        isLoading: false,
        error: e,
      ));
    }
  }

  /// Get data from the cache
  ///
  /// This method:
  /// 1. Sets loading state
  /// 2. Calls the cache service to fetch data
  /// 3. Updates state based on success or failure
  ///
  /// [forceRefresh] - If true, ignores cache and forces a network request
  ///
  /// Example:
  /// ```dart
  /// // Normal fetch (uses cache if valid)
  /// await repo.get();
  ///
  /// // Force refresh (bypasses cache)
  /// await repo.get(forceRefresh: true);
  /// ```
  Future<T?> get({bool forceRefresh = false}) async {
    return config.cache.get<T>(config: config, forceRefresh: forceRefresh);
  }

  /// Force refresh from the network
  ///
  /// Shorthand for `fetch(forceRefresh: true)`
  ///
  /// Example:
  /// ```dart
  /// await repo.refresh();
  /// ```
  Future<void> refresh() => fetch(forceRefresh: true);

  /// Invalidate the cache entry
  ///
  /// This removes the cache entry from storage and emits an update
  ///
  /// Example:
  /// ```dart
  /// await repo.invalidate();
  /// ```
  Future<void> invalidate() async {
    await config.cache.invalidate<T>(
      config: config,
    );
  }

  /// Dispose of the repository
  ///
  /// This cancels all subscriptions and closes the state stream.
  /// Always call this when the repository is no longer needed.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   repo.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _cacheSubscription?.cancel();
    _updateSubscription?.cancel();
    _stateController.close();
  }
}
