import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ttl_etag_cache/ttl_etag_cache_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTtlEtagCache platform = MethodChannelTtlEtagCache();
  const MethodChannel channel = MethodChannel('ttl_etag_cache');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
