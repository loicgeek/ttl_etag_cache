import 'package:neero_ttl_etag_cache/src/services/reactive_cache_dio.dart';

/// Configuration class for CachedTtlEtagRepository
class CachedTtlEtagConfig<T> {
  final ReactiveCacheDio cache;
  final String url;
  final String method;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Duration? defaultTtl;
  final T Function(dynamic) fromJson;
  final String Function(String url, Map<String, dynamic>? body)? getCacheKey;
  final String Function(dynamic responseData)? getDataFromResponseData;

  /// Create a new configuration for CachedTtlEtagRepository
  ///
  /// [url] - The URL to fetch data from
  /// [fromJson] - Function to deserialize JSON to type T
  /// [cache] - Optional ReactiveCacheDio instance (uses singleton by default)
  /// [method] - HTTP method (default: GET)
  /// [body] - Optional request body
  /// [headers] - Optional HTTP headers
  /// [defaultTtl] - Default time-to-live for cache entries
  /// [getCacheKey] - Optional custom cache key generator
  /// [getDataFromResponseData] - Optional response data extractor
  CachedTtlEtagConfig({
    required this.url,
    required this.fromJson,
    ReactiveCacheDio? cache,
    this.method = 'GET',
    this.body,
    this.headers,
    this.defaultTtl,
    this.getCacheKey,
    this.getDataFromResponseData,
  }) : cache = cache ?? ReactiveCacheDio();

  /// Create a copy of this config with some fields replaced
  CachedTtlEtagConfig<T> copyWith({
    ReactiveCacheDio? cache,
    String? url,
    Map<String, dynamic>? body,
    String? method,
    Map<String, String>? headers,
    Duration? defaultTtl,
    T Function(dynamic)? fromJson,
    String Function(String url, Map<String, dynamic>? body)? getCacheKey,
    String Function(dynamic responseData)? getDataFromResponseData,
  }) {
    return CachedTtlEtagConfig<T>(
      cache: cache ?? this.cache,
      url: url ?? this.url,
      body: body ?? this.body,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      defaultTtl: defaultTtl ?? this.defaultTtl,
      fromJson: fromJson ?? this.fromJson,
      getCacheKey: getCacheKey ?? this.getCacheKey,
      getDataFromResponseData:
          getDataFromResponseData ?? this.getDataFromResponseData,
    );
  }
}
