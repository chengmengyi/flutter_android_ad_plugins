package com.flutter.android.flutter_android_ad_plugins

import android.content.Context
import com.thinkup.debug.api.TUDebuggerUITest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterAndroidAdPluginsPlugin */
class FlutterAndroidAdPluginsPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_android_ad_plugins")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "showDebuggerUI" -> showDebuggerUI(call, result)
            else -> result.notImplemented()
        }
    }

    private fun showDebuggerUI(
        call: MethodCall,
        result: Result
    ) {
        try {
            val debugKey = call.argument<String>("debugKey")
            if (debugKey.isNullOrEmpty()) {
                TUDebuggerUITest.showDebuggerUI(context)
            } else {
                TUDebuggerUITest.showDebuggerUI(context, debugKey)
            }
            result.success(null)
        } catch (error: Throwable) {
            result.error("showDebuggerUI_failed", error.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
