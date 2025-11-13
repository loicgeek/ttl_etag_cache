import 'dart:async';
import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../ttl_etag_cache.dart';

/// Core caching service with TTL, ETag support, and optional encryption
///
/// This singleton service manages HTTP caching with:
/// - TTL (Time To Live) based expiration
/// - ETag conditional requests (304 Not Modified)
/// - Optional AES-256 encryption
/// - Reactive updates via broadcast streams
/// - Offline-first capabilities
///
/// Example:
/// ```dart
/// final cache = ReactiveCacheDio();
/// await cache.init(enableEncryption: true);
///
/// await cache.fetchReactive<User>(
///   url: 'https://api.example.com/user',
///   fromJson: (json) => User.fromJson(json),
///   defaultTtl: Duration(minutes: 5),
/// );
/// ```
class ReactiveCacheDio {
  static ReactiveCacheDio? _instance;
  late Isar isar;
  late Dio _dio;
  late bool _encryptionEnabled;
  EncryptionService? _encryption;

  final StreamController<void> _updateStreamController =
      StreamController.broadcast();

  /// Stream that emits whenever cache is updated
  ///
  /// Listen to this stream to be notified of any cache changes
  Stream<void> get updateStream => _updateStreamController.stream;

  ReactiveCacheDio._();

  /// Get the singleton instance
  factory ReactiveCacheDio() => _instance ??= ReactiveCacheDio._();

  /// Initialize the cache system
  ///
  /// [dio] - Optional Dio instance for HTTP requests
  /// [enableEncryption] - Enable AES-256 encryption for cached data
  ///
  /// This must be called before any cache operations.
  ///
  /// Example:
  /// ```dart
  /// await ReactiveCacheDio().init(
  ///   dio: customDio,
  ///   enableEncryption: true,
  /// );
  /// ```
  Future<void> init({
    Dio? dio,
    bool enableEncryption = false,
  }) async {
    _dio = dio ?? Dio();
    _encryptionEnabled = enableEncryption;

    if (_encryptionEnabled) {
      _encryption = EncryptionService();
      await _encryption!.init();
    }

    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [CachedTtlEtagResponseSchema],
      directory: dir.path,
    );
  }

  /// Whether encryption is currently enabled
  bool get isEncryptionEnabled => _encryptionEnabled;

  /// Generate a cache key from URL and optional body
  ///
  /// [url] - The request URL
  /// [body] - Optional request body
  ///
  /// Returns a unique cache key string
  String generateCacheKey(String url, Map<String, dynamic>? body) =>
      body == null ? url : '$url|${body.hashCode}';

  /// Calculate TTL from HTTP cache headers
  ///
  /// Checks for:
  /// - Cache-Control: max-age
  /// - Expires header
  ///
  /// Falls back to [defaultTtl] if no cache headers found
  Duration _calculateTtl(Map<String, String> headers, Duration? defaultTtl) {
    if (headers.containsKey('cache-control')) {
      final cc = headers['cache-control']!;
      final match = RegExp(r'max-age=(\d+)').firstMatch(cc);
      if (match != null) {
        return Duration(seconds: int.parse(match.group(1)!));
      }
    }
    if (headers.containsKey('expires')) {
      final expires = DateTime.tryParse(headers['expires']!);
      if (expires != null) {
        final ttl = expires.difference(DateTime.now());
        if (!ttl.isNegative) return ttl;
      }
    }
    return defaultTtl ?? Duration(minutes: 0);
  }

  /// Get cached entry by cache key
  Future<CachedTtlEtagResponse?> _getCachedEntry(String cacheKey) async {
    return await isar.cachedTtlEtagResponses
        .filter()
        .urlEqualTo(cacheKey)
        .findFirst();
  }

  /// Get decrypted data from cache entry
  ///
  /// Handles both plain and encrypted cache entries
  String? getDataFromCache(CachedTtlEtagResponse cached) {
    if (cached.isEncrypted) {
      if (!_encryptionEnabled || _encryption == null) {
        throw Exception('Cannot decrypt: encryption not enabled');
      }
      try {
        return _encryption!.decryptData(cached.encryptedData!, cached.iv!);
      } catch (e) {
        print('Decryption failed: $e');
        return null;
      }
    } else {
      return cached.data;
    }
  }

  /// Store cache entry with optional encryption
  Future<void> _storeCacheEntry({
    required String cacheKey,
    required String data,
    String? etag,
    required int ttlSeconds,
    Id? existingId,
  }) async {
    final newCache = CachedTtlEtagResponse()
      ..url = cacheKey
      ..etag = etag
      ..timestamp = DateTime.now()
      ..ttlSeconds = ttlSeconds
      ..isStale = false
      ..isEncrypted = _encryptionEnabled;

    if (existingId != null) {
      newCache.id = existingId;
    }

    if (_encryptionEnabled && _encryption != null) {
      // Store encrypted
      final encrypted = _encryption!.encryptData(data);
      newCache.encryptedData = encrypted.encryptedText;
      newCache.iv = encrypted.iv;
      newCache.data = null;
    } else {
      // Store plain
      newCache.data = data;
      newCache.encryptedData = null;
      newCache.iv = null;
    }

    await isar.writeTxn(() async {
      await isar.cachedTtlEtagResponses.put(newCache);
    });
    _updateStreamController.add(null);
  }

  /// Fetch data with reactive caching
  ///
  /// This method handles the complete fetch lifecycle:
  /// 1. Check cache validity (TTL)
  /// 2. Mark stale cache if expired
  /// 3. Send conditional request (If-None-Match, If-Modified-Since)
  /// 4. Handle 304 Not Modified or 200 OK
  /// 5. Update cache with encryption if enabled
  /// 6. Emit update event
  ///
  /// [url] - The URL to fetch
  /// [method] - HTTP method (GET, POST, etc.)
  /// [body] - Request body
  /// [headers] - HTTP headers
  /// [defaultTtl] - Default cache TTL if server doesn't specify
  /// [forceRefresh] - Force refresh ignoring cache
  /// [fromJson] - Function to deserialize response
  /// [getCacheKey] - Optional custom cache key generator
  /// [getDataFromResponseData] - Optional response data extractor
  ///
  /// Example:
  /// ```dart
  /// await cache.fetchReactive<User>(
  ///   url: 'https://api.example.com/user',
  ///   method: 'GET',
  ///   defaultTtl: Duration(minutes: 5),
  ///   fromJson: (json) => User.fromJson(json),
  /// );
  /// ```
  Future<void> fetchReactive<T>({
    required CacheTtlEtagConfig<T> config,
    bool forceRefresh = false,
  }) async {
    Map<String, dynamic> headers = config.headers ?? {};
    final cacheKey = config.getCacheKey?.call(config.url, config.body) ??
        generateCacheKey(config.url, config.body);

    CachedTtlEtagResponse? cached = await _getCachedEntry(cacheKey);

    // Cache is fresh - return early
    if (cached != null &&
        !forceRefresh &&
        DateTime.now().difference(cached.timestamp).inSeconds <
            cached.ttlSeconds) {
      return;
    }

    // Cache is stale - mark it but continue to fetch
    if (cached != null &&
        DateTime.now().difference(cached.timestamp).inSeconds >=
            cached.ttlSeconds) {
      cached.isStale = true;
      await isar.writeTxn(() async {
        await isar.cachedTtlEtagResponses.put(cached);
      });
      _updateStreamController.add(null);
    }

    // Add conditional request headers
    if (cached != null) {
      if (cached.etag != null) headers['If-None-Match'] = cached.etag!;
      headers['If-Modified-Since'] = cached.timestamp.toUtc().toIso8601String();
    }

    try {
      final response = await _dio.request(
        config.url,
        data: config.body,
        options: Options(method: config.method, headers: headers),
      );

      final jsonData =
          config.getDataFromResponseData?.call(response.data) ?? response.data;
      final etag = response.headers.value('etag');
      final ttl = _calculateTtl(
        response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        config.defaultTtl,
      );

      await _storeCacheEntry(
        cacheKey: cacheKey,
        data: jsonEncode(jsonData),
        etag: etag,
        ttlSeconds: ttl.inSeconds,
        existingId: cached?.id,
      );
    } on DioException catch (e) {
      var response = e.response;
      // Handle 304 Not Modified
      if ((response?.statusCode ?? 0) == 304 && cached != null) {
        cached.timestamp = DateTime.now();
        cached.isStale = false;
        final ttl = _calculateTtl(
          response!.headers.map.map((k, v) => MapEntry(k, v.join(','))),
          config.defaultTtl,
        );
        cached.ttlSeconds = ttl.inSeconds;
        await isar.writeTxn(() async {
          await isar.cachedTtlEtagResponses.put(cached);
        });
        _updateStreamController.add(null);
      } else {
        rethrow;
      }
    } catch (_) {
      rethrow;
    }
  }

  /// Invalidate (delete) a specific cache entry
  ///
  /// [config] - The configuration for the cache entry to invalidate
  ///
  /// Example:
  /// ```dart
  /// await cache.invalidate<User>(
  ///   config: CacheTtlEtagConfig<User>(
  ///     url: 'https://api.example.com/user/123',
  ///     fromJson: (json) => User.fromJson(json),
  ///   ),
  /// );
  /// ```
  Future<void> invalidate<T>({
    required CacheTtlEtagConfig<T> config,
  }) async {
    final cacheKey = config.getCacheKey?.call(config.url, config.body) ??
        generateCacheKey(config.url, config.body);
    await isar.writeTxn(() async {
      final cached = await _getCachedEntry(cacheKey);
      if (cached != null) {
        await isar.cachedTtlEtagResponses.delete(cached.id);
      }
    });
    _updateStreamController.add(null);
  }

  /// Clear all cached data
  ///
  /// Example:
  /// ```dart
  /// await cache.clearAll();
  /// ```
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.cachedTtlEtagResponses.clear();
    });
    _updateStreamController.add(null);
  }

  /// Clear all cache and reset encryption key
  ///
  /// Use this on logout or when security requires a complete reset
  ///
  /// Example:
  /// ```dart
  /// await cache.clearAndResetEncryption();
  /// ```
  Future<void> clearAndResetEncryption() async {
    await clearAll();
    if (_encryptionEnabled && _encryption != null) {
      await _encryption!.resetKey();
    }
  }

  /// Migrate cache between encryption modes
  ///
  /// This allows enabling or disabling encryption on existing cache data.
  /// The migration re-encrypts or decrypts all cache entries.
  ///
  /// [enableEncryption] - True to encrypt, false to decrypt
  ///
  /// **Warning:** This operation can take time if you have many cache entries.
  ///
  /// Example:
  /// ```dart
  /// // Enable encryption on existing plain cache
  /// await cache.migrateEncryption(enableEncryption: true);
  ///
  /// // Disable encryption and convert to plain text
  /// await cache.migrateEncryption(enableEncryption: false);
  /// ```
  Future<void> migrateEncryption({required bool enableEncryption}) async {
    if (_encryptionEnabled == enableEncryption) {
      return; // No migration needed
    }

    // Initialize encryption if enabling
    if (enableEncryption && _encryption == null) {
      _encryption = EncryptionService();
      await _encryption!.init();
    }

    final allCached = await isar.cachedTtlEtagResponses.where().findAll();

    await isar.writeTxn(() async {
      for (final cached in allCached) {
        if (enableEncryption && !cached.isEncrypted) {
          // Encrypt plain data
          if (cached.data != null) {
            final encrypted = _encryption!.encryptData(cached.data!);
            cached.encryptedData = encrypted.encryptedText;
            cached.iv = encrypted.iv;
            cached.data = null;
            cached.isEncrypted = true;
          }
        } else if (!enableEncryption && cached.isEncrypted) {
          // Decrypt encrypted data
          if (cached.encryptedData != null && _encryption != null) {
            try {
              cached.data = _encryption!.decryptData(
                cached.encryptedData!,
                cached.iv!,
              );
              cached.encryptedData = null;
              cached.iv = null;
              cached.isEncrypted = false;
            } catch (e) {
              // Skip entries that can't be decrypted
              print('Failed to decrypt entry: ${cached.url}');
              continue;
            }
          }
        }
        await isar.cachedTtlEtagResponses.put(cached);
      }
    });

    _encryptionEnabled = enableEncryption;
    _updateStreamController.add(null);
  }

  /// Clean up duplicate cache entries
  ///
  /// This method is useful after migration or if duplicate entries exist.
  /// It keeps the newest entry for each unique URL.
  ///
  /// Example:
  /// ```dart
  /// await cache.cleanupDuplicates();
  /// ```
  Future<void> cleanupDuplicates() async {
    await isar.writeTxn(() async {
      final allCached = await isar.cachedTtlEtagResponses.where().findAll();
      final urlToEntry = <String, CachedTtlEtagResponse>{};

      for (final entry in allCached) {
        if (urlToEntry.containsKey(entry.url)) {
          // Keep the newer entry
          final existing = urlToEntry[entry.url]!;
          if (entry.timestamp.isAfter(existing.timestamp)) {
            await isar.cachedTtlEtagResponses.delete(existing.id);
            urlToEntry[entry.url] = entry;
          } else {
            await isar.cachedTtlEtagResponses.delete(entry.id);
          }
        } else {
          urlToEntry[entry.url] = entry;
        }
      }
    });
  }

  /// Get cache statistics
  ///
  /// Returns information about the current cache state
  ///
  /// Example:
  /// ```dart
  /// final stats = await cache.getStatistics();
  /// print('Total entries: ${stats.totalEntries}');
  /// print('Encrypted entries: ${stats.encryptedEntries}');
  /// ```
  Future<CacheStatistics> getStatistics() async {
    final all = await isar.cachedTtlEtagResponses.where().findAll();
    final encrypted = all.where((e) => e.isEncrypted).length;
    final stale = all.where((e) => e.isStale).length;
    final expired = all.where((e) => e.isExpired).length;

    return CacheStatistics(
      totalEntries: all.length,
      encryptedEntries: encrypted,
      plainEntries: all.length - encrypted,
      staleEntries: stale,
      expiredEntries: expired,
    );
  }
}

/// Cache statistics information
class CacheStatistics {
  final int totalEntries;
  final int encryptedEntries;
  final int plainEntries;
  final int staleEntries;
  final int expiredEntries;

  const CacheStatistics({
    required this.totalEntries,
    required this.encryptedEntries,
    required this.plainEntries,
    required this.staleEntries,
    required this.expiredEntries,
  });

  @override
  String toString() {
    return 'CacheStatistics(total: $totalEntries, encrypted: $encryptedEntries, '
        'plain: $plainEntries, stale: $staleEntries, expired: $expiredEntries)';
  }
}
