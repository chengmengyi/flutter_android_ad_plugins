import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_android_ad_plugins_method_channel.dart';

abstract class FlutterAndroidAdPluginsPlatform extends PlatformInterface {
  /// Constructs a FlutterAndroidAdPluginsPlatform.
  FlutterAndroidAdPluginsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAndroidAdPluginsPlatform _instance = MethodChannelFlutterAndroidAdPlugins();

  /// The default instance of [FlutterAndroidAdPluginsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAndroidAdPlugins].
  static FlutterAndroidAdPluginsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAndroidAdPluginsPlatform] when
  /// they register themselves.
  static set instance(FlutterAndroidAdPluginsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> load() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
