import 'dart:async';
import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/cached_ttl_etag_response.dart';

class ReactiveCacheDio {
  static ReactiveCacheDio? _instance;
  late Isar isar;
  final Dio _dio = Dio();

  final StreamController<void> _updateStreamController =
      StreamController.broadcast();
  Stream<void> get updateStream => _updateStreamController.stream;

  ReactiveCacheDio._();
  factory ReactiveCacheDio() => _instance ??= ReactiveCacheDio._();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([CachedTtlEtagResponseSchema], directory: dir.path);
  }

  String generateCacheKey(String url, Map<String, dynamic>? body) =>
      body == null ? url : '$url|${body.hashCode}';

  Duration _calculateTtl(Map<String, String> headers, Duration? defaultTtl) {
    if (headers.containsKey('cache-control')) {
      final cc = headers['cache-control']!;
      final match = RegExp(r'max-age=(\d+)').firstMatch(cc);
      if (match != null) return Duration(seconds: int.parse(match.group(1)!));
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

  Future<void> fetchReactive<T>({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? defaultTtl,
    bool forceRefresh = false,
    required T Function(dynamic) fromJson,
    String Function(String url, Map<String, dynamic>? body)? getCacheKey,
    String Function(dynamic responseData)? getDataFromResponseData,
  }) async {
    headers ??= {};
    final cacheKey =
        getCacheKey?.call(url, body) ?? generateCacheKey(url, body);

    CachedTtlEtagResponse? cached = await isar.cachedTtlEtagResponses
        .filter()
        .urlEqualTo(cacheKey)
        .findFirst();

    // Cache fresh
    if (cached != null &&
        !forceRefresh &&
        DateTime.now().difference(cached.timestamp).inSeconds <
            cached.ttlSeconds) {
      return;
    }

    // Cache stale
    if (cached != null &&
        DateTime.now().difference(cached.timestamp).inSeconds >=
            cached.ttlSeconds) {
      cached.isStale = true;
      await isar.writeTxn(() async {
        await isar.cachedTtlEtagResponses.put(cached!);
      });
      _updateStreamController.add(null);
    }

    // Headers conditionnels GET
    if (cached != null) {
      if (cached.etag != null) headers['If-None-Match'] = cached.etag!;
      headers['If-Modified-Since'] = cached.timestamp.toUtc().toIso8601String();
    }

    try {
      final response = await _dio.request(
        url,
        data: body,
        options: Options(method: method, headers: headers),
      );

      if ((response.statusCode ?? 0) == 200) {
        final jsonData =
            getDataFromResponseData?.call(response.data) ?? response.data;
        final etag = response.headers.value('etag');
        final ttl = _calculateTtl(
          response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
          defaultTtl,
        );

        final newCache = CachedTtlEtagResponse<T>()
          ..url = cacheKey
          ..data = jsonEncode(jsonData)
          ..etag = etag
          ..timestamp = DateTime.now()
          ..ttlSeconds = ttl.inSeconds
          ..isStale = false;

        await isar.writeTxn(() async {
          await isar.cachedTtlEtagResponses.put(newCache);
        });

        _updateStreamController.add(null);
      } else if ((response.statusCode ?? 0) == 304 && cached != null) {
        cached.timestamp = DateTime.now();
        cached.isStale = false;
        await isar.writeTxn(() async {
          await isar.cachedTtlEtagResponses.put(cached!);
        });
        _updateStreamController.add(null);
      }
    } catch (_) {
      // fallback sur cache stale existant
      cached ??= cached;
      rethrow;
    }
  }

  Future<void> invalidate<T>({
    required String url,
    Map<String, dynamic>? body,
    String Function(String url, Map<String, dynamic>? body)? getCacheKey,
  }) async {
    final cacheKey =
        getCacheKey?.call(url, body) ?? generateCacheKey(url, body);
    await isar.writeTxn(() async {
      final cached = await isar.cachedTtlEtagResponses
          .filter()
          .urlEqualTo(cacheKey)
          .findFirst();

      if (cached != null) await isar.cachedTtlEtagResponses.delete(cached.id);
    });
    _updateStreamController.add(null);
  }
}
