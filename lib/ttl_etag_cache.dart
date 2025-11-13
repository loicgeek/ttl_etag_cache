library ttl_etag_cache;

import 'package:dio/dio.dart';
import 'src/models/cache_ttl_etag_config.dart';
import 'src/services/reactive_cache_dio.dart';

export 'src/interceptors/cache_ttl_etag_interceptor.dart';
export 'src/models/cache_ttl_etag_state.dart';
export 'src/models/cached_ttl_etag_response.dart';
export 'src/repositories/cached_ttl_etag_repository.dart';
export 'src/services/encryption_service.dart';
export 'src/models/cache_ttl_etag_config.dart';

/// Main entry point for Neero TTL/ETag Cache
///
/// A powerful, reactive caching solution for Flutter applications with:
/// - TTL (Time To Live) support
/// - ETag conditional requests
/// - Optional AES-256 encryption
/// - Reactive stream-based updates
/// - Offline-first capabilities
class TtlEtagCache {
  /// Initialize the cache system
  ///
  /// [dio] - Optional Dio instance for HTTP requests
  /// [enableEncryption] - Enable AES-256 encryption for cached data
  ///
  /// Example:
  /// ```dart
  /// await TtlEtagCache.init(
  ///   enableEncryption: true,
  /// );
  /// ```
  static Future<void> init({
    Dio? dio,
    bool enableEncryption = false,
  }) {
    return ReactiveCacheDio().init(
      dio: dio,
      enableEncryption: enableEncryption,
    );
  }

  /// Invalidate (delete) a specific cache entry
  ///
  /// [url] - The URL of the cached resource
  /// [body] - Optional request body used to generate the cache key
  /// [getCacheKey] - Optional custom cache key generator
  ///
  /// Example:
  /// ```dart
  /// await TtlEtagCache.invalidate<User>(
  ///   url: 'https://api.example.com/user/123',
  /// );
  /// ```
  static Future<void> invalidate<T>({
    required CacheTtlEtagConfig<T> config,
  }) async {
    return ReactiveCacheDio().invalidate<T>(
      config: config,
    );
  }

  /// Fetch or refetch data with caching
  ///
  /// This method handles the complete fetch lifecycle including:
  /// - Cache validation
  /// - Conditional requests (If-None-Match, If-Modified-Since)
  /// - TTL management
  /// - Automatic cache updates
  ///
  /// [url] - The URL to fetch
  /// [method] - HTTP method (GET, POST, etc.)
  /// [body] - Request body
  /// [headers] - HTTP headers
  /// [defaultTtl] - Default time-to-live for cache entries
  /// [forceRefresh] - Force a refresh ignoring cache
  /// [fromJson] - Function to deserialize the response
  /// [getCacheKey] - Optional custom cache key generator
  /// [getDataFromResponseData] - Optional response data extractor
  ///
  /// Example:
  /// ```dart
  /// await TtlEtagCache.refetch<User>(
  ///   url: 'https://api.example.com/user/123',
  ///   defaultTtl: Duration(minutes: 5),
  ///   fromJson: (json) => User.fromJson(json),
  /// );
  /// ```
  static Future<void> refetch<T>({
    required CacheTtlEtagConfig<T> config,
    bool forceRefresh = false,
  }) async {
    return ReactiveCacheDio().fetchReactive<T>(
      config: config,
      forceRefresh: forceRefresh,
    );
  }

  /// Clear all cached data
  ///
  /// Example:
  /// ```dart
  /// await TtlEtagCache.clearAll();
  /// ```
  static Future<void> clearAll() {
    return ReactiveCacheDio().clearAll();
  }

  /// Clear all cache and reset encryption key (if encryption is enabled)
  ///
  /// Use this method on logout or when security requires a complete reset
  ///
  /// Example:
  /// ```dart
  /// await TtlEtagCache.clearAndResetEncryption();
  /// ```
  static Future<void> clearAndResetEncryption() {
    return ReactiveCacheDio().clearAndResetEncryption();
  }

  /// Migrate cache between encryption modes
  ///
  /// This allows you to enable or disable encryption on existing cache data
  ///
  /// [enableEncryption] - True to encrypt, false to decrypt
  ///
  /// Example:
  /// ```dart
  /// // Enable encryption on existing plain cache
  /// await TtlEtagCache.migrateEncryption(enableEncryption: true);
  /// ```
  static Future<void> migrateEncryption({required bool enableEncryption}) {
    return ReactiveCacheDio().migrateEncryption(
      enableEncryption: enableEncryption,
    );
  }

  /// Check if encryption is currently enabled
  static bool get isEncryptionEnabled => ReactiveCacheDio().isEncryptionEnabled;
}
