import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import '../../neero_ttl_etag_cache.dart';
import '../services/reactive_cache_dio.dart';

/// Dio interceptor for automatic caching with TTL and ETag support
///
/// This interceptor can be added to any existing Dio instance to enable
/// automatic caching without modifying existing code.
///
/// Features:
/// - Transparent caching (no code changes needed)
/// - TTL-based expiration
/// - ETag conditional requests
/// - Optional encryption
/// - Configurable per-endpoint rules
/// - Cache invalidation support
///
/// Example:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   CacheTtlEtagInterceptor(
///     enableEncryption: true,
///     defaultTtl: Duration(minutes: 5),
///   ),
/// );
///
/// // All requests now automatically cached!
/// final response = await dio.get('https://api.example.com/user');
/// ```
class CacheTtlEtagInterceptor extends Interceptor {
  final ReactiveCacheDio _cache;
  final Duration? defaultTtl;
  final bool enableEncryption;
  final CacheStrategy defaultStrategy;
  final Map<String, CacheRule> rules;
  final String Function(String url, Map<String, dynamic>? body)? getCacheKey;

  bool _isInitialized = false;

  /// Create a new cache interceptor
  ///
  /// [cache] - Optional ReactiveCacheDio instance (creates new if not provided)
  /// [defaultTtl] - Default cache time-to-live
  /// [enableEncryption] - Enable AES-256 encryption
  /// [defaultStrategy] - Default caching strategy for all requests
  /// [rules] - Per-endpoint cache rules
  /// [getCacheKey] - Custom cache key generator
  CacheTtlEtagInterceptor({
    ReactiveCacheDio? cache,
    this.defaultTtl,
    this.enableEncryption = false,
    this.defaultStrategy = CacheStrategy.cacheFirst,
    this.rules = const {},
    this.getCacheKey,
  }) : _cache = cache ?? ReactiveCacheDio();

  /// Initialize the interceptor (called automatically on first request)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _cache.init(enableEncryption: enableEncryption);
    _isInitialized = true;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _ensureInitialized();

    // Determine cache strategy for this request
    final strategy = _getStrategyForRequest(options);

    // Skip caching if strategy is networkOnly or if method is not cacheable
    if (strategy == CacheStrategy.networkOnly || !_isCacheable(options)) {
      return handler.next(options);
    }

    // Check for force refresh header
    final forceRefresh = options.headers['X-Force-Refresh'] == 'true';
    options.headers.remove('X-Force-Refresh');

    try {
      final cacheKey = _generateCacheKey(options);
      final cached = await _cache.isar.cachedTtlEtagResponses
          .filter()
          .urlEqualTo(cacheKey)
          .findFirst();

      // Cache hit and still fresh
      if (cached != null &&
          !forceRefresh &&
          DateTime.now().difference(cached.timestamp).inSeconds <
              cached.ttlSeconds) {
        if (strategy == CacheStrategy.cacheFirst ||
            strategy == CacheStrategy.cacheOnly) {
          // Return cached response
          handler.resolve(
            _createResponseFromCache(options, cached),
            true,
          );
          return;
        }
      }

      // Cache exists but stale - add conditional headers
      if (cached != null && strategy != CacheStrategy.networkFirst) {
        if (cached.etag != null) {
          options.headers['If-None-Match'] = cached.etag!;
        }
        options.headers['If-Modified-Since'] =
            cached.timestamp.toUtc().toIso8601String();
      }

      // Store cache info in extra for response handler
      options.extra['_cache_key'] = cacheKey;
      options.extra['_cached_entry'] = cached;
      options.extra['_cache_ttl'] = _getTtlForRequest(options);

      handler.next(options);
    } catch (e) {
      // On error, continue with network request
      handler.next(options);
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      final cacheKey = response.requestOptions.extra['_cache_key'] as String?;
      final cached = response.requestOptions.extra['_cached_entry']
          as CachedTtlEtagResponse?;
      final ttl = response.requestOptions.extra['_cache_ttl'] as Duration?;

      if (cacheKey == null) {
        return handler.next(response);
      }

      // Handle 304 Not Modified
      if (response.statusCode == 304 && cached != null) {
        // Update TTL and return cached data
        cached.timestamp = DateTime.now();
        cached.isStale = false;
        cached.ttlSeconds = ttl?.inSeconds ??
            _calculateTtlFromHeaders(response.headers.map).inSeconds;

        await _cache.isar.writeTxn(() async {
          await _cache.isar.cachedTtlEtagResponses.put(cached);
        });

        // Return cached response
        handler.resolve(
          _createResponseFromCache(response.requestOptions, cached),
        );
        return;
      }

      // Handle 200 OK - store in cache
      if (response.statusCode == 200) {
        final calculatedTtl =
            ttl ?? _calculateTtlFromHeaders(response.headers.map);

        await _storeInCache(
          cacheKey: cacheKey,
          data: response.data,
          etag: response.headers.value('etag'),
          ttl: calculatedTtl,
          existingId: cached?.id,
        );
      }

      handler.next(response);
    } catch (e) {
      // On error, still return the response
      handler.next(response);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // On network error, try to return stale cache
      final strategy = _getStrategyForRequest(err.requestOptions);

      if (strategy == CacheStrategy.cacheFirst ||
          strategy == CacheStrategy.staleWhileRevalidate) {
        final cacheKey = err.requestOptions.extra['_cache_key'] as String?;

        if (cacheKey != null) {
          final cached = await _cache.isar.cachedTtlEtagResponses
              .filter()
              .urlEqualTo(cacheKey)
              .findFirst();

          if (cached != null) {
            // Return stale cache instead of error
            handler
                .resolve(_createResponseFromCache(err.requestOptions, cached));
            return;
          }
        }
      }

      handler.next(err);
    } catch (e) {
      handler.next(err);
    }
  }

  /// Generate cache key for request
  String _generateCacheKey(RequestOptions options) {
    if (getCacheKey != null) {
      return getCacheKey!(
        options.uri.toString(),
        options.data is Map ? options.data as Map<String, dynamic> : null,
      );
    }

    final url = options.uri.toString();
    if (options.data == null) return url;

    return '$url|${options.data.hashCode}';
  }

  /// Check if request method is cacheable
  bool _isCacheable(RequestOptions options) {
    // Only cache GET requests by default
    // Can be extended to cache POST with specific rules
    return options.method.toUpperCase() == 'GET';
  }

  /// Get cache strategy for specific request
  CacheStrategy _getStrategyForRequest(RequestOptions options) {
    // Check for custom header
    final strategyHeader = options.headers['X-Cache-Strategy'] as String?;
    options.headers.remove('X-Cache-Strategy');

    if (strategyHeader != null) {
      return CacheStrategy.values.firstWhere(
        (s) => s.name == strategyHeader,
        orElse: () => defaultStrategy,
      );
    }

    // Check rules for this endpoint
    for (final entry in rules.entries) {
      if (options.uri.toString().contains(entry.key)) {
        return entry.value.strategy;
      }
    }

    return defaultStrategy;
  }

  /// Get TTL for specific request
  Duration? _getTtlForRequest(RequestOptions options) {
    // Check rules for this endpoint
    for (final entry in rules.entries) {
      if (options.uri.toString().contains(entry.key)) {
        return entry.value.ttl;
      }
    }

    return defaultTtl;
  }

  /// Calculate TTL from response headers
  Duration _calculateTtlFromHeaders(Map<String, List<String>> headers) {
    final flatHeaders = headers.map((k, v) => MapEntry(k, v.join(',')));

    if (flatHeaders.containsKey('cache-control')) {
      final cc = flatHeaders['cache-control']!;
      final match = RegExp(r'max-age=(\d+)').firstMatch(cc);
      if (match != null) {
        return Duration(seconds: int.parse(match.group(1)!));
      }
    }

    if (flatHeaders.containsKey('expires')) {
      final expires = DateTime.tryParse(flatHeaders['expires']!);
      if (expires != null) {
        final ttl = expires.difference(DateTime.now());
        if (!ttl.isNegative) return ttl;
      }
    }

    return defaultTtl ?? Duration(minutes: 5);
  }

  /// Store data in cache
  Future<void> _storeInCache({
    required String cacheKey,
    required dynamic data,
    String? etag,
    required Duration ttl,
    Id? existingId,
  }) async {
    final jsonData = jsonEncode(data);

    final newCache = CachedTtlEtagResponse()
      ..url = cacheKey
      ..etag = etag
      ..timestamp = DateTime.now()
      ..ttlSeconds = ttl.inSeconds
      ..isStale = false
      ..isEncrypted = enableEncryption;

    if (existingId != null) {
      newCache.id = existingId;
    }

    if (enableEncryption) {
      final encryption = EncryptionService();
      if (!encryption.isInitialized) {
        await encryption.init();
      }

      final encrypted = encryption.encryptData(jsonData);
      newCache.encryptedData = encrypted.encryptedText;
      newCache.iv = encrypted.iv;
      newCache.data = null;
    } else {
      newCache.data = jsonData;
      newCache.encryptedData = null;
      newCache.iv = null;
    }

    await _cache.isar.writeTxn(() async {
      await _cache.isar.cachedTtlEtagResponses.put(newCache);
    });
  }

  /// Create Response from cached entry
  Response _createResponseFromCache(
    RequestOptions options,
    CachedTtlEtagResponse cached,
  ) {
    // Decrypt if needed
    String rawData;
    if (cached.isEncrypted) {
      final encryption = EncryptionService();
      rawData = encryption.decryptData(cached.encryptedData!, cached.iv!);
    } else {
      rawData = cached.data!;
    }

    final data = jsonDecode(rawData);

    return Response(
      requestOptions: options,
      data: data,
      statusCode: 200,
      headers: Headers.fromMap({
        'x-cache-hit': ['true'],
        'x-cache-age': [
          '${DateTime.now().difference(cached.timestamp).inSeconds}'
        ],
        'x-cache-stale': ['${cached.isStale}'],
      }),
    );
  }

  /// Invalidate cache for a specific URL pattern
  Future<void> invalidate(String urlPattern) async {
    await _cache.isar.writeTxn(() async {
      final matches = await _cache.isar.cachedTtlEtagResponses
          .filter()
          .urlContains(urlPattern)
          .findAll();

      for (final entry in matches) {
        await _cache.isar.cachedTtlEtagResponses.delete(entry.id);
      }
    });
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _cache.clearAll();
  }
}

/// Cache strategy options
enum CacheStrategy {
  /// Try cache first, fallback to network
  cacheFirst,

  /// Try network first, fallback to cache
  networkFirst,

  /// Only use cache, never network
  cacheOnly,

  /// Only use network, never cache
  networkOnly,

  /// Return stale cache immediately, refresh in background
  staleWhileRevalidate,
}

/// Cache rule for specific endpoints
class CacheRule {
  /// Cache strategy to use
  final CacheStrategy strategy;

  /// Time-to-live for this endpoint
  final Duration? ttl;

  /// Whether to cache this endpoint
  final bool enabled;

  const CacheRule({
    this.strategy = CacheStrategy.cacheFirst,
    this.ttl,
    this.enabled = true,
  });

  /// Convenient constructors
  const CacheRule.cacheFirst({Duration? ttl})
      : this(strategy: CacheStrategy.cacheFirst, ttl: ttl);

  const CacheRule.networkFirst({Duration? ttl})
      : this(strategy: CacheStrategy.networkFirst, ttl: ttl);

  const CacheRule.cacheOnly({Duration? ttl})
      : this(strategy: CacheStrategy.cacheOnly, ttl: ttl);

  const CacheRule.networkOnly()
      : this(strategy: CacheStrategy.networkOnly, enabled: false);

  const CacheRule.staleWhileRevalidate({Duration? ttl})
      : this(strategy: CacheStrategy.staleWhileRevalidate, ttl: ttl);
}
