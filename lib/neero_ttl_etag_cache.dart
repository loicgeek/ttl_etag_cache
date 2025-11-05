import 'package:neero_ttl_etag_cache/src/services/reactive_ttl_etag_cache_dio.dart';
export 'src/services/reactive_ttl_etag_cache_dio.dart';
export 'src/models/cached_ttl_etag_response.dart';
export 'src/widgets/generic_ttl_etag_cache_viewer.dart';

class NeeroTtlEtagCache {
  static Future<void> init() {
    return ReactiveCacheDio().init();
  }

  static Future<void> invalidate<T>({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return ReactiveCacheDio().invalidate<T>(url: url, body: body);
  }

  static Future<void> refetch<T>({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? defaultTtl,
    bool forceRefresh = false,
    required T Function(dynamic) fromJson,
  }) async {
    return ReactiveCacheDio().fetchReactive<T>(
      url: url,
      method: method,
      body: body,
      headers: headers,
      defaultTtl: defaultTtl,
      forceRefresh: forceRefresh,
      fromJson: fromJson,
    );
  }
}
