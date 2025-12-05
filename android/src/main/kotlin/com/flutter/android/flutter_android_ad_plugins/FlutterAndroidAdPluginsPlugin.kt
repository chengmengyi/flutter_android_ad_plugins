package com.flutter.android.flutter_android_ad_plugins

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import sg.bigo.ads.BigoAdSdk
import sg.bigo.ads.BigoAdSdk.InitListener
import sg.bigo.ads.api.AdConfig
import sg.bigo.ads.api.AdError
import sg.bigo.ads.api.AdLoadListener
import sg.bigo.ads.api.popup.PopupAd
import sg.bigo.ads.api.popup.PopupAdLoader
import sg.bigo.ads.api.popup.PopupAdRequest


/** FlutterAndroidAdPluginsPlugin */
class FlutterAndroidAdPluginsPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var mApplicationContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_android_ad_plugins")
        channel.setMethodCallHandler(this)
        mApplicationContext = flutterPluginBinding.getApplicationContext()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method){
            "init"-> init()
            "load"-> load()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun init(){
        Log.e("qwer", "init")
        val config = AdConfig.Builder()
            .setAppId("11052391")
            .build()
        if(null!=mApplicationContext){
            Log.e("qwer", "mApplicationContext")
            BigoAdSdk.initialize(mApplicationContext!!, config, object : InitListener {
                override fun onInitialized() {
                    Log.e("qwer", "onInitialized")
                }
            })
        }
    }
    private fun load(){
        Log.e("qwer", "kk==onError=====load")
        val popupAdRequest = PopupAdRequest.Builder()
            .withSlotId("11052391-11262090")
            .withAge(20)
            .withGender(AdConfig.GENDER_MALE)
            .build()

        val popupAdLoader = PopupAdLoader.Builder().withAdLoadListener(object : AdLoadListener<PopupAd> {
            override fun onError(p0: AdError) {
                Log.e("qwer", "kk==onError==${p0.code}===${p0.message}")
            }

            override fun onAdLoaded(p0: PopupAd) {
                Log.e("qwer", "kk==onAdLoaded==")
            }
        }).build()
        popupAdLoader.loadAd(popupAdRequest)
    }
}
