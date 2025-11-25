import 'package:flutter_test/flutter_test.dart';
import 'package:ttl_etag_cache/ttl_etag_cache.dart';
import 'package:ttl_etag_cache/ttl_etag_cache_platform_interface.dart';
import 'package:ttl_etag_cache/ttl_etag_cache_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTtlEtagCachePlatform
    with MockPlatformInterfaceMixin
    implements TtlEtagCachePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TtlEtagCachePlatform initialPlatform = TtlEtagCachePlatform.instance;

  test('$MethodChannelTtlEtagCache is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTtlEtagCache>());
  });

  test('getPlatformVersion', () async {
    TtlEtagCache ttlEtagCachePlugin = TtlEtagCache();
    MockTtlEtagCachePlatform fakePlatform = MockTtlEtagCachePlatform();
    TtlEtagCachePlatform.instance = fakePlatform;

    expect(await ttlEtagCachePlugin.getPlatformVersion(), '42');
  });
}
