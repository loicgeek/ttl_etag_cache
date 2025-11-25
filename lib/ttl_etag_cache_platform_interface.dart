import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ttl_etag_cache_method_channel.dart';

abstract class TtlEtagCachePlatform extends PlatformInterface {
  /// Constructs a TtlEtagCachePlatform.
  TtlEtagCachePlatform() : super(token: _token);

  static final Object _token = Object();

  static TtlEtagCachePlatform _instance = MethodChannelTtlEtagCache();

  /// The default instance of [TtlEtagCachePlatform] to use.
  ///
  /// Defaults to [MethodChannelTtlEtagCache].
  static TtlEtagCachePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TtlEtagCachePlatform] when
  /// they register themselves.
  static set instance(TtlEtagCachePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
