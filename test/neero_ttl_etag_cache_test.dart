import 'package:flutter_test/flutter_test.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache_platform_interface.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNeeroTtlEtagCachePlatform
    with MockPlatformInterfaceMixin
    implements NeeroTtlEtagCachePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NeeroTtlEtagCachePlatform initialPlatform = NeeroTtlEtagCachePlatform.instance;

  test('$MethodChannelNeeroTtlEtagCache is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNeeroTtlEtagCache>());
  });

  test('getPlatformVersion', () async {
    NeeroTtlEtagCache neeroTtlEtagCachePlugin = NeeroTtlEtagCache();
    MockNeeroTtlEtagCachePlatform fakePlatform = MockNeeroTtlEtagCachePlatform();
    NeeroTtlEtagCachePlatform.instance = fakePlatform;

    expect(await neeroTtlEtagCachePlugin.getPlatformVersion(), '42');
  });
}
