import 'package:isar_community/isar.dart';

part 'cached_ttl_etag_response.g.dart';

@collection
class CachedTtlEtagResponse<T> {
  Id id = Isar.autoIncrement;

  /// Clé unique pour GET ou POST
  late String url;

  late String data;

  String? etag;

  late DateTime timestamp;

  late int ttlSeconds;

  bool isStale = false;
}
