import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ttl_etag_cache_platform_interface.dart';

/// An implementation of [TtlEtagCachePlatform] that uses method channels.
class MethodChannelTtlEtagCache extends TtlEtagCachePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ttl_etag_cache');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
