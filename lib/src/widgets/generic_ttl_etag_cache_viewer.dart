import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import 'package:neero_ttl_etag_cache/src/models/cached_ttl_etag_response.dart';
import '../services/reactive_ttl_etag_cache_dio.dart';

typedef CacheFullBuilder<T> =
    Widget Function(
      BuildContext context, {
      T? data,
      bool isStale,
      bool isFetching,
      Object? error,
      DateTime? timestamp,
      int? ttlSeconds,
      String? etag,
      VoidCallback? onRetry,
    });

class GenericTtlEtagCacheViewer<T> extends StatefulWidget {
  final String url;
  final Map<String, dynamic>? body;
  final String method;
  final Map<String, String>? headers;
  final CacheFullBuilder<T> builder;
  final T Function(dynamic) fromJson;

  const GenericTtlEtagCacheViewer({
    Key? key,
    required this.url,
    required this.fromJson,
    required this.builder,
    this.method = 'GET',
    this.body,
    this.headers,
  }) : super(key: key);

  @override
  GenericTtlEtagCacheViewerState<T> createState() =>
      GenericTtlEtagCacheViewerState<T>();
}

class GenericTtlEtagCacheViewerState<T>
    extends State<GenericTtlEtagCacheViewer<T>> {
  late ReactiveCacheDio cache;
  bool isFetching = false;
  Object? error;

  @override
  void initState() {
    super.initState();
    cache = ReactiveCacheDio();
    _fetch();
  }

  void _fetch() async {
    setState(() => isFetching = true);
    try {
      await cache.fetchReactive<T>(
        url: widget.url,
        method: widget.method,
        body: widget.body,
        headers: widget.headers,
        fromJson: widget.fromJson,
      );
      setState(() => error = null);
    } catch (e) {
      setState(() => error = e);
    } finally {
      setState(() => isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CachedTtlEtagResponse<dynamic>>>(
      stream: cache.isar.cachedTtlEtagResponses
          .watchLazy(fireImmediately: true)
          .asyncMap((_) async {
            final results = await cache.isar.cachedTtlEtagResponses
                .filter()
                .urlEqualTo(cache.generateCacheKey(widget.url, widget.body))
                .findAll();

            return results.cast<CachedTtlEtagResponse<dynamic>>();
          }),
      builder: (context, snapshot) {
        final cached = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!.first
            : null;

        final T? typedData = cached?.data != null
            ? widget.fromJson(jsonDecode(cached!.data))
            : null;

        return widget.builder(
          context,
          data: typedData,
          isStale: cached?.isStale ?? false,
          isFetching: isFetching,
          error: error,
          timestamp: cached?.timestamp,
          ttlSeconds: cached?.ttlSeconds,
          etag: cached?.etag,
          onRetry: _fetch,
        );
      },
    );
  }
}
