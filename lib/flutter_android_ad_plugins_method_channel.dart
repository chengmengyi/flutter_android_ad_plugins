import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_android_ad_plugins_platform_interface.dart';

/// An implementation of [FlutterAndroidAdPluginsPlatform] that uses method channels.
class MethodChannelFlutterAndroidAdPlugins extends FlutterAndroidAdPluginsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_android_ad_plugins');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
