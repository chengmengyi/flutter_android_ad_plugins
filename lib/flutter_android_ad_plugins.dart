import 'dart:async';
import 'dart:convert';
import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_android_ad_plugins/data/ad_money_info_bean.dart';
import 'package:flutter_android_ad_plugins/data/config_ad_data.dart';
import 'package:flutter_android_ad_plugins/data/load_result_data.dart';
import 'package:flutter_android_ad_plugins/data/topon_ad_info_bean.dart';
import 'package:flutter_android_ad_plugins/hep/ad_num_hep.dart';
import 'package:flutter_android_ad_plugins/hep/ad_type.dart';
import 'package:flutter_android_ad_plugins/hep/ios_ad_callback.dart';
import 'package:flutter_android_ad_plugins/hep/ios_load_ad_result_callback.dart';
import 'package:flutter_android_ad_plugins/load/new_load_ios_ad.dart';
import 'package:thinkup_sdk/at_init.dart';
import 'package:thinkup_sdk/at_interstitial.dart';
import 'package:thinkup_sdk/at_interstitial_response.dart';
import 'package:thinkup_sdk/at_listener.dart';
import 'package:thinkup_sdk/at_rewarded.dart';
import 'package:thinkup_sdk/at_rewarded_response.dart';
import 'package:flutter_android_ad_plugins/hep/hep.dart';

typedef FengKongLogic = bool Function();

class FlutterAndroidAdPlugins {
  static final FlutterAndroidAdPlugins _flutterAndroidAdPlugins =
      FlutterAndroidAdPlugins();
  static FlutterAndroidAdPlugins get instance => _flutterAndroidAdPlugins;

  //新方案加载插屏和激励
  NewLoadIosAd? _newIntLoadIosAd;
  NewLoadIosAd? _newRvLoadIosAd;
  var _adShowing = false, _priceSwitch = false, _hasReward = false;
  IosAdCallback? _iosAdCallback;
  FengKongLogic? _fengKongLogic;
  StreamSubscription<dynamic>? _rewardedVideoSubscription;
  StreamSubscription<dynamic>? _interstitialSubscription;

  initMax({
    // required String maxKey,
    required String topOnAppId,
    required String topOnAppKey,
    required ConfigAdData data,
    required FengKongLogic fengKongLogic,
    required IosLoadAdResultCallback iosLoadAdResultCallback,
    // bool showMediationDebugger=false,
    // bool? userConsent,
    // bool? doNotSell,
  }) async {
    _fengKongLogic = fengKongLogic;

    // if(maxKey.isNotEmpty){
    //   var startInitMax = DateTime.now().millisecondsSinceEpoch;
    //   if(null!=userConsent){
    //     AppLovinMAX.setHasUserConsent(userConsent);
    //   }
    //   if(null!=doNotSell){
    //     AppLovinMAX.setDoNotSell(doNotSell);
    //   }
    //   await AppLovinMAX.initialize(maxKey);
    //   var maxInitTime = DateTime.now().millisecondsSinceEpoch-startInitMax;
    //   iosLoadAdResultCallback.initSdkSuccess.call(maxInitTime,"max");
    // }
    if (topOnAppId.isNotEmpty) {
      var startInitTopon = DateTime.now().millisecondsSinceEpoch;
      await ATInitManger.initAnyThinkSDK(
        appidStr: topOnAppId,
        appidkeyStr: topOnAppKey,
      );
      var toponInitTime =
          DateTime.now().millisecondsSinceEpoch - startInitTopon;
      iosLoadAdResultCallback.initSdkSuccess.call(toponInitTime, "topon");
    }

    // if(kDebugMode&&showMediationDebugger){
    //   AppLovinMAX.showMediationDebugger();
    // }
    // if(maxKey.isNotEmpty){
    //   _setMaxAdListener();
    // }
    if (topOnAppId.isNotEmpty) {
      await _setTopOnListener();
    }
    _newIntLoadIosAd = NewLoadIosAd(
      interAd: true,
      iosLoadAdResultCallback: iosLoadAdResultCallback,
    );
    _newRvLoadIosAd = NewLoadIosAd(
      interAd: false,
      iosLoadAdResultCallback: iosLoadAdResultCallback,
    );
    updateAdData(data);
  }

  // _setMaxAdListener(){
  //   AppLovinMAX.setRewardedAdListener(
  //       RewardedAdListener(
  //         onAdLoadedCallback: (ad){
  //           _newIntLoadIosAd?.loadAdSuccess(_createAdMoneyInfoByMax(ad));
  //           _newRvLoadIosAd?.loadAdSuccess(_createAdMoneyInfoByMax(ad));
  //         },
  //         onAdLoadFailedCallback: (ad,error){
  //           _newIntLoadIosAd?.loadAdFail(ad,"code:${error.code},message:${error.message}");
  //           _newRvLoadIosAd?.loadAdFail(ad,"code:${error.code},message:${error.message}");
  //         },
  //         onAdDisplayedCallback: (ad){
  //           _adShowing=true;
  //           _hasReward=false;
  //           _deleteAdCache(ad.adUnitId);
  //           AdNumHep.instance.updateShowNum();
  //           _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
  //         },
  //         onAdDisplayFailedCallback: (ad,error){
  //           _adShowing=false;
  //           _hasReward=false;
  //           _deleteAdCache(ad.adUnitId);
  //           loadAd(_getAdInfoBeanById(ad.adUnitId));
  //           _iosAdCallback?.showFail.call(_getAdInfoBeanById(ad.adUnitId));
  //         },
  //         onAdClickedCallback: (ad){
  //           AdNumHep.instance.updateClickNum();
  //         },
  //         onAdHiddenCallback: (ad){
  //           _adShowing=false;
  //           loadAd(_getAdInfoBeanById(ad.adUnitId));
  //           _iosAdCallback?.closeAd.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId),_hasReward);
  //         },
  //         onAdReceivedRewardCallback: (ad,reward){
  //           _hasReward=true;
  //         },
  //         onAdRevenuePaidCallback: (ad){
  //           _iosAdCallback?.revenuePaid.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
  //         },
  //       )
  //   );
  //
  //   AppLovinMAX.setInterstitialListener(
  //       InterstitialListener(
  //         onAdLoadedCallback: (ad){
  //           _newIntLoadIosAd?.loadAdSuccess(_createAdMoneyInfoByMax(ad));
  //           _newRvLoadIosAd?.loadAdSuccess(_createAdMoneyInfoByMax(ad));
  //         },
  //         onAdLoadFailedCallback: (ad,error){
  //           _newIntLoadIosAd?.loadAdFail(ad,"code:${error.code},message:${error.message}");
  //           _newRvLoadIosAd?.loadAdFail(ad,"code:${error.code},message:${error.message}");
  //         },
  //         onAdDisplayedCallback: (ad){
  //           _adShowing=true;
  //           _hasReward=false;
  //           _deleteAdCache(ad.adUnitId);
  //           AdNumHep.instance.updateShowNum();
  //           _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
  //         },
  //         onAdDisplayFailedCallback: (ad,error){
  //           _adShowing=false;
  //           _hasReward=false;
  //           _deleteAdCache(ad.adUnitId);
  //           loadAd(_getAdInfoBeanById(ad.adUnitId));
  //           _iosAdCallback?.showFail.call(_getAdInfoBeanById(ad.adUnitId));
  //         },
  //         onAdClickedCallback: (ad){
  //           AdNumHep.instance.updateClickNum();
  //         },
  //         onAdHiddenCallback: (ad){
  //           _adShowing=false;
  //           loadAd(_getAdInfoBeanById(ad.adUnitId));
  //           _iosAdCallback?.closeAd.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId),_hasReward);
  //         },
  //         onAdRevenuePaidCallback: (ad){
  //           _iosAdCallback?.revenuePaid.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
  //         },
  //       )
  //   );
  // }

  Future<void> _setTopOnListener() async {
    await _rewardedVideoSubscription?.cancel();
    await _interstitialSubscription?.cancel();

    _rewardedVideoSubscription = ATListenerManager.rewardedVideoEventHandler.listen((
      event,
    ) async {
      var adUnitId = event.placementID;
      switch (event.rewardStatus) {
        //广告加载失败
        case RewardedStatus.rewardedVideoDidFailToLoad:
          _newIntLoadIosAd?.loadAdFail(
            adUnitId,
            "message:${event.requestMessage}",
          );
          _newRvLoadIosAd?.loadAdFail(
            adUnitId,
            "message:${event.requestMessage}",
          );
          break;
        //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告加载成功--->${adMoneyInfoBean.toString()}".log();
          _newIntLoadIosAd?.loadAdSuccess(adMoneyInfoBean);
          _newRvLoadIosAd?.loadAdSuccess(adMoneyInfoBean);
          break;
        //广告展示成功
        case RewardedStatus.rewardedVideoDidStartPlaying:
          _adShowing = true;
          _hasReward = false;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告展示成功--->${adMoneyInfoBean.toString()}".log();
          _iosAdCallback?.showSuccess.call(
            adMoneyInfoBean,
            _getAdInfoBeanById(adUnitId),
          );
          break;
        //广告展示失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
          _adShowing = false;
          _hasReward = false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.showFail.call(_getAdInfoBeanById(adUnitId));
          break;
        //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          AdNumHep.instance.updateClickNum();
          break;
        //激励发放成功
        case RewardedStatus.rewardedVideoDidRewardSuccess:
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          _hasReward = true;
          break;
        //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          _adShowing = false;
          loadAd(_getAdInfoBeanById(adUnitId));
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告被关闭--->${adMoneyInfoBean.toString()}".log();
          _iosAdCallback?.closeAd.call(
            adMoneyInfoBean,
            _getAdInfoBeanById(adUnitId),
            _hasReward,
          );
          _hasReward = false;
          break;
        default:
          break;
      }
    });

    _interstitialSubscription = ATListenerManager.interstitialEventHandler.listen((
      event,
    ) async {
      var adUnitId = event.placementID;
      switch (event.interstatus) {
        //广告加载失败
        case InterstitialStatus.interstitialAdFailToLoadAD:
          "flutter ios ad --->load fail--->reason--->${event.requestMessage}"
              .log();
          _newIntLoadIosAd?.loadAdFail(
            adUnitId,
            "message:${event.requestMessage}",
          );
          _newRvLoadIosAd?.loadAdFail(
            adUnitId,
            "message:${event.requestMessage}",
          );
          break;
        //广告加载成功
        case InterstitialStatus.interstitialAdDidFinishLoading:
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告加载成功--->${adMoneyInfoBean.toString()}".log();
          _newIntLoadIosAd?.loadAdSuccess(adMoneyInfoBean);
          _newRvLoadIosAd?.loadAdSuccess(adMoneyInfoBean);
          break;
        //广告展示成功
        case InterstitialStatus.interstitialDidShowSucceed:
          _adShowing = true;
          _hasReward = false;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告展示成功--->${adMoneyInfoBean.toString()}".log();
          _iosAdCallback?.showSuccess.call(
            adMoneyInfoBean,
            _getAdInfoBeanById(adUnitId),
          );
          break;
        //广告展示失败
        case InterstitialStatus.interstitialFailedToShow:
          _adShowing = false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.showFail.call(_getAdInfoBeanById(adUnitId));
          break;
        //广告被点击
        case InterstitialStatus.interstitialAdDidClick:
          AdNumHep.instance.updateClickNum();
          break;
        //广告被关闭
        case InterstitialStatus.interstitialAdDidClose:
          _adShowing = false;
          loadAd(_getAdInfoBeanById(adUnitId));
          var adMoneyInfoBean = await _createAdMoneyInfoByTopOn(
            adUnitId,
            event.extraMap,
          );
          // "flutter ios ad --->广告被关闭--->${adMoneyInfoBean.toString()}".log();
          _iosAdCallback?.closeAd.call(
            adMoneyInfoBean,
            _getAdInfoBeanById(adUnitId),
            _hasReward,
          );
          break;
        default:
          break;
      }
    });
  }

  // AdMoneyInfoBean _createAdMoneyInfoByMax(MaxAd? ad)=>AdMoneyInfoBean(
  //   adUnitId: ad?.adUnitId??"",
  //   revenue: ad?.revenue??0.0,
  //   networkName: ad?.networkName??"",
  //   revenuePrecision: ad?.revenuePrecision??"",
  // );

  Future<AdMoneyInfoBean> _createAdMoneyInfoByTopOn(
    String adUnitId,
    Map extraMap,
  ) async {
    try {
      var infoData = _getAdInfoBeanById(adUnitId);
      String s = "";
      if (infoData?.adType == AdType.interstitial) {
        s = await ATInterstitialManager.getInterstitialValidAds(
          placementID: adUnitId,
        );
      }
      if (infoData?.adType == AdType.reward) {
        s = await ATRewardedManager.getRewardedVideoValidAds(
          placementID: adUnitId,
        );
      }
      // "flutter ios ad --->_createAdMoneyInfoByTopOn--->adUnitId:$adUnitId--->$s".log();
      if (s.isNotEmpty) {
        var topOnAdInfoList = _getTopOnAdInfoList(s);
        var indexWhere = topOnAdInfoList.indexWhere(
          (value) => value.adunitId == adUnitId,
        );
        // "flutter ios ad --->s.isNotEmpty--->${topOnAdInfoList.length}====${indexWhere}".log();
        if (indexWhere >= 0) {
          var toponAdInfoBean = topOnAdInfoList[indexWhere];
          return AdMoneyInfoBean(
            adUnitId: toponAdInfoBean.adunitId ?? "",
            revenue: toponAdInfoBean.publisherRevenue ?? 0,
            networkName: toponAdInfoBean.networkType ?? "",
            revenuePrecision: toponAdInfoBean.precision ?? "",
          );
        }
      }
      return AdMoneyInfoBean(
        adUnitId: adUnitId,
        revenue: extraMap["publisher_revenue"] ?? 0,
        networkName: extraMap["network_name"] ?? "",
        revenuePrecision: extraMap["precision"] ?? "",
      );
    } catch (e) {
      return AdMoneyInfoBean(
        adUnitId: "",
        revenue: 0.0,
        networkName: "",
        revenuePrecision: "",
      );
    }
  }

  List<ToponAdInfoBean> _getTopOnAdInfoList(String s) {
    try {
      List<ToponAdInfoBean> list = [];
      var json = jsonDecode(s);
      if (json != null && json is List) {
        for (var v in json) {
          list.add(ToponAdInfoBean.fromJson(v));
        }
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  showAd({required AdType adType, required IosAdCallback iosAdCallback}) async {
    if (_adShowing) {
      "flutter ios ad --->ad showing".log();
      iosAdCallback.showFail.call(null);
      return;
    }
    if (checkFk()) {
      "flutter ios ad --->fengkong not show ad".log();
      iosAdCallback.showFail.call(null);
      return;
    }
    _iosAdCallback = iosAdCallback;
    var resultData = getCacheResultData(adType);
    if (null != resultData) {
      var newAdType = resultData.adBean.adType;
      var adPlat = resultData.adBean.adPlat;
      var adId = resultData.adBean.adId;
      "flutter ios ad --->start show ad --->type:$adType--->adPlat:$adPlat---->${resultData.adBean.toString()}"
          .log();
      if (newAdType == AdType.reward) {
        // if(adPlat=="max"){
        //   if(await AppLovinMAX.isRewardedAdReady(adId)==true){
        //     AppLovinMAX.showRewardedAd(adId);
        //   }else{
        //     "flutter ios ad --->$newAdType not Ready".log();
        //     _deleteAdCache(adId);
        //     _iosAdCallback?.showFail.call(null);
        //     loadAd(resultData.adBean);
        //   }
        // }else
        if (adPlat == "topon") {
          if (await ATRewardedManager.rewardedVideoReady(placementID: adId) ==
              true) {
            ATRewardedManager.showRewardedVideo(placementID: adId);
          } else {
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call(null);
            loadAd(resultData.adBean);
          }
        } else {
          _deleteAdCache(adId);
          _iosAdCallback?.showFail.call(null);
          loadAd(resultData.adBean);
        }
      } else if (newAdType == AdType.interstitial) {
        // if(adPlat=="max"){
        //   if(await AppLovinMAX.isInterstitialReady(adId)==true){
        //     AppLovinMAX.showInterstitial(adId);
        //   }else{
        //     "flutter ios ad --->$newAdType not Ready".log();
        //     _deleteAdCache(adId);
        //     _iosAdCallback?.showFail.call(null);
        //     loadAd(resultData.adBean);
        //   }
        // }else
        if (adPlat == "topon") {
          if (await ATInterstitialManager.hasInterstitialAdReady(
                placementID: adId,
              ) ==
              true) {
            ATInterstitialManager.showInterstitialAd(placementID: adId);
          } else {
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call(null);
            loadAd(resultData.adBean);
          }
        } else {
          _deleteAdCache(adId);
          _iosAdCallback?.showFail.call(null);
          loadAd(resultData.adBean);
        }
      }
    } else {
      loadAdWhenNoCache(adType);
      _iosAdCallback?.showFail.call(null);
    }
  }

  loadAd(AdInfoData? infoData) {
    if (null == infoData) {
      return;
    }
    _newIntLoadIosAd?.loadAdById(infoData);
    _newRvLoadIosAd?.loadAdById(infoData);
  }

  loadAdWhenNoCache(AdType adType) {
    if (adType == AdType.interstitial) {
      _newIntLoadIosAd?.loadAllAd();
    } else if (adType == AdType.reward) {
      _newRvLoadIosAd?.loadAllAd();
    }
  }

  _deleteAdCache(String id) {
    _newIntLoadIosAd?.deleteCache(id);
    _newRvLoadIosAd?.deleteCache(id);
  }

  AdInfoData? _getAdInfoBeanById(String id) {
    var adBean = _newIntLoadIosAd?.getAdInfoBeanById(id);
    adBean ??= _newRvLoadIosAd?.getAdInfoBeanById(id);
    return adBean;
  }

  LoadResultData? getCacheResultData(AdType adType) {
    if (adType == AdType.interstitial) {
      var cashAd = _newIntLoadIosAd?.getCashAd();
      "flutter ios ad --->get int cache--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}"
          .log();
      return cashAd;
    } else if (adType == AdType.reward) {
      if (!_priceSwitch) {
        var cashAd = _newRvLoadIosAd?.getCashAd();
        "flutter ios ad --->get rv cache--->only contrast rv--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}"
            .log();
        return cashAd;
      } else {
        var list =
            (_newIntLoadIosAd?.getHasCacheResultList() ?? []) +
            (_newRvLoadIosAd?.getHasCacheResultList() ?? []);
        if (list.isEmpty) {
          "flutter ios ad --->get rv cache--->contrast rv and int--->ID: no--->revenue: no"
              .log();
          return null;
        }
        list.sort((a, b) => (b.revenue).compareTo(a.revenue));
        var first = list.first;
        "flutter ios ad --->get rv cache--->contrast rv and int--->ID: ${first.adBean.adId}--->revenue: ${first.revenue}"
            .log();
        return first;
      }
    } else {
      return null;
    }
  }

  updateAdData(ConfigAdData data) {
    _priceSwitch = data.priceSwitch;
    AdNumHep.instance.setMaxNum(data.maxShowNum, data.maxClickNum);
    _newIntLoadIosAd?.updateAdList(data.newInterList);
    _newRvLoadIosAd?.updateAdList(data.newRewardList);
  }

  bool adShowing() => _adShowing;

  bool checkFk() {
    if (null == _fengKongLogic) {
      return false;
    }
    return _fengKongLogic!();
  }

  setEverydayWatchAdNum(int maxShow) {
    AdNumHep.instance.setFkMaxShowNum(maxShow);
  }
}
