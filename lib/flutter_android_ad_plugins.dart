import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_android_ad_plugins/data/ad_money_info_bean.dart';
import 'package:flutter_android_ad_plugins/data/config_ad_data.dart';
import 'package:flutter_android_ad_plugins/data/load_result_data.dart';
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
  static final FlutterAndroidAdPlugins _flutterAndroidAdPlugins=FlutterAndroidAdPlugins();
  static FlutterAndroidAdPlugins get instance => _flutterAndroidAdPlugins;

  //新方案加载插屏和激励
  NewLoadIosAd? _newIntLoadIosAd;
  NewLoadIosAd? _newRvLoadIosAd;
  //风控用户加载
  NewLoadIosAd? _fkIntLoadIosAd;
  NewLoadIosAd? _fkRvLoadIosAd;
  var _adShowing=false,_priceSwitch=false,_fkPriceSwitch=false,_hasReward=false,_hasInitSdk=false;
  IosAdCallback? _iosAdCallback;
  FengKongLogic? _fengKongLogic;

  initMax({
    required String maxKey,
    required String topOnAppId,
    required String topOnAppKey,
    required ConfigAdData data,
    required FengKongLogic fengKongLogic,
    required IosLoadAdResultCallback iosLoadAdResultCallback,
    bool showMediationDebugger=false,
  })async{
    _fengKongLogic=fengKongLogic;

    var startInitMax = DateTime.now().millisecondsSinceEpoch;
    AppLovinMAX.setHasUserConsent(true);
    AppLovinMAX.setDoNotSell(false);
    await AppLovinMAX.initialize(maxKey);
    var maxInitTime = DateTime.now().millisecondsSinceEpoch-startInitMax;
    iosLoadAdResultCallback.initSdkSuccess.call(maxInitTime,"max");

    var startInitTopon = DateTime.now().millisecondsSinceEpoch;
    await ATInitManger.initAnyThinkSDK(appidStr: topOnAppId, appidkeyStr: topOnAppKey);
    var toponInitTime = DateTime.now().millisecondsSinceEpoch-startInitTopon;
    iosLoadAdResultCallback.initSdkSuccess.call(toponInitTime,"topon");
    if(kDebugMode&&showMediationDebugger){
      AppLovinMAX.showMediationDebugger();
    }
    _setMaxAdListener();
    _setTopOnListener();
    _newIntLoadIosAd=NewLoadIosAd(interAd: true, iosLoadAdResultCallback: iosLoadAdResultCallback);
    _newRvLoadIosAd=NewLoadIosAd(interAd: false, iosLoadAdResultCallback: iosLoadAdResultCallback);

    _fkIntLoadIosAd=NewLoadIosAd(interAd: true, iosLoadAdResultCallback: iosLoadAdResultCallback);
    _fkRvLoadIosAd=NewLoadIosAd(interAd: false, iosLoadAdResultCallback: iosLoadAdResultCallback);
    _hasInitSdk=true;
    updateAdData(data);
  }

  _setMaxAdListener(){
    AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
          onAdLoadedCallback: (ad){
            var info = _createAdMoneyInfoByMax(ad);
            _newIntLoadIosAd?.loadAdSuccess(info);
            _newRvLoadIosAd?.loadAdSuccess(info);
            _fkIntLoadIosAd?.loadAdSuccess(info);
            _fkRvLoadIosAd?.loadAdSuccess(info);
          },
          onAdLoadFailedCallback: (ad,error){
            _newIntLoadIosAd?.loadAdFail(ad);
            _newRvLoadIosAd?.loadAdFail(ad);
            _fkIntLoadIosAd?.loadAdFail(ad);
            _fkRvLoadIosAd?.loadAdFail(ad);
          },
          onAdDisplayedCallback: (ad){
            _adShowing=true;
            _hasReward=false;
            _deleteAdCache(ad.adUnitId);
            AdNumHep.instance.updateShowNum();
            _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
          },
          onAdDisplayFailedCallback: (ad,error){
            _adShowing=false;
            _hasReward=false;
            _deleteAdCache(ad.adUnitId);
            loadAd(_getAdInfoBeanById(ad.adUnitId));
            _iosAdCallback?.showFail.call();
          },
          onAdClickedCallback: (ad){
            AdNumHep.instance.updateClickNum();
          },
          onAdHiddenCallback: (ad){
            _adShowing=false;
            loadAd(_getAdInfoBeanById(ad.adUnitId));
            _iosAdCallback?.closeAd.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId),_hasReward);
          },
          onAdReceivedRewardCallback: (ad,reward){
            _hasReward=true;
          },
          onAdRevenuePaidCallback: (ad){
            _iosAdCallback?.revenuePaid.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
          },
        )
    );

    AppLovinMAX.setInterstitialListener(
        InterstitialListener(
          onAdLoadedCallback: (ad){
            var info = _createAdMoneyInfoByMax(ad);
            _newIntLoadIosAd?.loadAdSuccess(info);
            _newRvLoadIosAd?.loadAdSuccess(info);
            _fkRvLoadIosAd?.loadAdSuccess(info);
            _fkIntLoadIosAd?.loadAdSuccess(info);
          },
          onAdLoadFailedCallback: (ad,error){
            _newIntLoadIosAd?.loadAdFail(ad);
            _newRvLoadIosAd?.loadAdFail(ad);
            _fkRvLoadIosAd?.loadAdFail(ad);
            _fkIntLoadIosAd?.loadAdFail(ad);
          },
          onAdDisplayedCallback: (ad){
            _adShowing=true;
            _hasReward=false;
            _deleteAdCache(ad.adUnitId);
            AdNumHep.instance.updateShowNum();
            _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
          },
          onAdDisplayFailedCallback: (ad,error){
            _adShowing=false;
            _hasReward=false;
            _deleteAdCache(ad.adUnitId);
            loadAd(_getAdInfoBeanById(ad.adUnitId));
            _iosAdCallback?.showFail.call();
          },
          onAdClickedCallback: (ad){
            AdNumHep.instance.updateClickNum();
          },
          onAdHiddenCallback: (ad){
            _adShowing=false;
            loadAd(_getAdInfoBeanById(ad.adUnitId));
            _iosAdCallback?.closeAd.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId),_hasReward);
          },
          onAdRevenuePaidCallback: (ad){
            _iosAdCallback?.revenuePaid.call(_createAdMoneyInfoByMax(ad),_getAdInfoBeanById(ad.adUnitId));
          },
        )
    );
  }

  _setTopOnListener(){
    ATListenerManager.rewardedVideoEventHandler.listen((event) {
      var adUnitId = event.placementID;
      switch (event.rewardStatus) {
      //广告加载失败
        case RewardedStatus.rewardedVideoDidFailToLoad:
          "flutter ios ad --->load fail--->reason--->${event.requestMessage}".log();
          _newIntLoadIosAd?.loadAdFail(adUnitId);
          _newRvLoadIosAd?.loadAdFail(adUnitId);
          _fkIntLoadIosAd?.loadAdFail(adUnitId);
          _fkRvLoadIosAd?.loadAdFail(adUnitId);
          break;
      //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          _hasReward=true;
          var info = _createAdMoneyInfoByTopOn(adUnitId,event.extraMap);
          _newIntLoadIosAd?.loadAdSuccess(info);
          _newRvLoadIosAd?.loadAdSuccess(info);
          _fkRvLoadIosAd?.loadAdSuccess(info);
          _fkIntLoadIosAd?.loadAdSuccess(info);
          break;
      //广告展示成功
        case RewardedStatus.rewardedVideoDidStartPlaying:
          _adShowing=true;
          _hasReward=false;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByTopOn(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId));
          break;
      //广告展示失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
          _adShowing=false;
          _hasReward=false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.showFail.call();
          break;
      //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          AdNumHep.instance.updateClickNum();
          break;
      //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          _adShowing=false;
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.closeAd.call(_createAdMoneyInfoByTopOn(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId),_hasReward);
          break;
        default:

          break;
      }
    });

    ATListenerManager.interstitialEventHandler.listen((event) {
      var adUnitId = event.placementID;
      switch (event.interstatus) {
      //广告加载失败
        case InterstitialStatus.interstitialAdFailToLoadAD:
          _newIntLoadIosAd?.loadAdFail(adUnitId);
          _newRvLoadIosAd?.loadAdFail(adUnitId);
          _fkIntLoadIosAd?.loadAdFail(adUnitId);
          _fkRvLoadIosAd?.loadAdFail(adUnitId);
          break;
      //广告加载成功
        case InterstitialStatus.interstitialAdDidFinishLoading:
          var info = _createAdMoneyInfoByTopOn(adUnitId,event.extraMap);
          _newIntLoadIosAd?.loadAdSuccess(info);
          _newRvLoadIosAd?.loadAdSuccess(info);
          _fkRvLoadIosAd?.loadAdSuccess(info);
          _fkIntLoadIosAd?.loadAdSuccess(info);
          break;
      //广告展示成功
        case InterstitialStatus.interstitialDidShowSucceed:
          _adShowing=true;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          _iosAdCallback?.showSuccess.call(_createAdMoneyInfoByTopOn(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId));
          break;
      //广告展示失败
        case InterstitialStatus.interstitialFailedToShow:
          _adShowing=false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.showFail.call();
          break;
      //广告被点击
        case InterstitialStatus.interstitialAdDidClick:
          AdNumHep.instance.updateClickNum();
          break;
      //广告被关闭
        case InterstitialStatus.interstitialAdDidClose:
          _adShowing=false;
          loadAd(_getAdInfoBeanById(adUnitId));
          _iosAdCallback?.closeAd.call(_createAdMoneyInfoByTopOn(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId),_hasReward);
          break;
        default:

          break;
      }
    });
  }

  AdMoneyInfoBean _createAdMoneyInfoByMax(MaxAd? ad)=>AdMoneyInfoBean(
    adUnitId: ad?.adUnitId??"",
    revenue: ad?.revenue??0.0,
    networkName: ad?.networkName??"",
    revenuePrecision: ad?.revenuePrecision??"",
  );

  AdMoneyInfoBean _createAdMoneyInfoByTopOn(String adUnitId,Map extraMap){
    try{
      return AdMoneyInfoBean(
        adUnitId: adUnitId,
        revenue: extraMap["publisher_revenue"]??0,
        networkName: extraMap["network_name"]??"",
        revenuePrecision: extraMap["precision"]??"",
      );
    }catch(e){
      return AdMoneyInfoBean(
        adUnitId: "",
        revenue: 0.0,
        networkName: "",
        revenuePrecision: "",
      );
    }
  }

  showAd({
    required AdType adType,
    required IosAdCallback iosAdCallback,
  })async{
    if(_adShowing){
      "flutter ios ad --->ad showing".log();
      iosAdCallback.showFail.call();
      return;
    }
    // if(checkFk()){
    //   "flutter ios ad --->fengkong not show ad".log();
    //   iosAdCallback.showFail.call();
    //   return;
    // }
    _iosAdCallback=iosAdCallback;
    var resultData = getCacheResultData(adType);
    if(null!=resultData){
      var newAdType = resultData.adBean.adType;
      var adPlat = resultData.adBean.adPlat;
      var adId = resultData.adBean.adId;
      "flutter ios ad --->start show ad --->type:$adType--->adPlat:$adPlat---->${resultData.adBean.toString()}".log();
      if(newAdType==AdType.reward){
        if(adPlat=="max"){
          if(await AppLovinMAX.isRewardedAdReady(adId)==true){
            AppLovinMAX.showRewardedAd(adId);
          }else{
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call();
            loadAd(resultData.adBean);
          }
        }else if(adPlat=="topon"){
          if(await ATRewardedManager.rewardedVideoReady(placementID: adId)==true){
            ATRewardedManager.showRewardedVideo(placementID: adId);
          }else{
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call();
            loadAd(resultData.adBean);
          }
        }else{
          _deleteAdCache(adId);
          _iosAdCallback?.showFail.call();
          loadAd(resultData.adBean);
        }
      }else if(newAdType==AdType.interstitial){
        if(adPlat=="max"){
          if(await AppLovinMAX.isInterstitialReady(adId)==true){
            AppLovinMAX.showInterstitial(adId);
          }else{
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call();
            loadAd(resultData.adBean);
          }
        }else if(adPlat=="topon"){
          if(await ATInterstitialManager.hasInterstitialAdReady(placementID: adId)==true){
            ATInterstitialManager.showInterstitialAd(placementID: adId);
          }else{
            "flutter ios ad --->$newAdType not Ready".log();
            _deleteAdCache(adId);
            _iosAdCallback?.showFail.call();
            loadAd(resultData.adBean);
          }
        } else{
          _deleteAdCache(adId);
          _iosAdCallback?.showFail.call();
          loadAd(resultData.adBean);
        }
      }
    }else{
      loadAdWhenNoCache(adType);
      _iosAdCallback?.showFail.call();
    }
  }

  loadAd(AdInfoData? infoData){
    if(null==infoData){
      return;
    }
    _newIntLoadIosAd?.loadAdById(infoData);
    _newRvLoadIosAd?.loadAdById(infoData);
  }

  loadAdWhenNoCache(AdType adType){
    if(checkFk()){
      if(adType==AdType.interstitial){
        _fkIntLoadIosAd?.loadAllAd();
      }else if(adType==AdType.reward){
        _fkRvLoadIosAd?.loadAllAd();
      }
    }else{
      if(adType==AdType.interstitial){
        _newIntLoadIosAd?.loadAllAd();
      }else if(adType==AdType.reward){
        _newRvLoadIosAd?.loadAllAd();
      }
    }
  }

  _deleteAdCache(String id){
    _newIntLoadIosAd?.deleteCache(id);
    _newRvLoadIosAd?.deleteCache(id);
    _fkRvLoadIosAd?.deleteCache(id);
    _fkIntLoadIosAd?.deleteCache(id);
  }

  AdInfoData? _getAdInfoBeanById(String id){
    var adBean = _newIntLoadIosAd?.getAdInfoBeanById(id);
    adBean ??= _newRvLoadIosAd?.getAdInfoBeanById(id);
    adBean ??= _fkIntLoadIosAd?.getAdInfoBeanById(id);
    adBean ??= _fkRvLoadIosAd?.getAdInfoBeanById(id);
    return adBean;
  }

  LoadResultData? getCacheResultData(AdType adType){
    if(checkFk()){
      if(adType==AdType.interstitial){
        var cashAd = _fkIntLoadIosAd?.getCashAd();
        "flutter ios ad --->get int cache--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}".log();
        return cashAd;
      }else if(adType==AdType.reward){
        if(!_fkPriceSwitch){
          var cashAd = _fkRvLoadIosAd?.getCashAd();
          "flutter ios ad --->get rv cache--->only contrast rv--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}".log();
          return cashAd;
        }else{
          var list = (_fkIntLoadIosAd?.getHasCacheResultList()??[])+(_fkRvLoadIosAd?.getHasCacheResultList()??[]);
          if(list.isEmpty){
            "flutter ios ad --->get rv cache--->contrast rv and int--->ID: no--->revenue: no".log();
            return null;
          }
          list.sort((a, b) => (b.revenue).compareTo(a.revenue));
          var first = list.first;
          "flutter ios ad --->get rv cache--->contrast rv and int--->ID: ${first.adBean.adId}--->revenue: ${first.revenue}".log();
          return first;
        }
      }else{
        return null;
      }
    }else{
      if(adType==AdType.interstitial){
        var cashAd = _newIntLoadIosAd?.getCashAd();
        "flutter ios ad --->get int cache--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}".log();
        return cashAd;
      }else if(adType==AdType.reward){
        if(!_priceSwitch){
          var cashAd = _newRvLoadIosAd?.getCashAd();
          "flutter ios ad --->get rv cache--->only contrast rv--->ID: ${cashAd?.adBean.adId}--->revenue:${cashAd?.revenue}".log();
          return cashAd;
        }else{
          var list = (_newIntLoadIosAd?.getHasCacheResultList()??[])+(_newRvLoadIosAd?.getHasCacheResultList()??[]);
          if(list.isEmpty){
            "flutter ios ad --->get rv cache--->contrast rv and int--->ID: no--->revenue: no".log();
            return null;
          }
          list.sort((a, b) => (b.revenue).compareTo(a.revenue));
          var first = list.first;
          "flutter ios ad --->get rv cache--->contrast rv and int--->ID: ${first.adBean.adId}--->revenue: ${first.revenue}".log();
          return first;
        }
      }else{
        return null;
      }
    }
  }

  updateAdData(ConfigAdData data){
    if(!_hasInitSdk){
      return;
    }
    _priceSwitch=data.priceSwitch;
    _newIntLoadIosAd?.updateAdList(data.newInterList);
    _newRvLoadIosAd?.updateAdList(data.newRewardList);
  }

  bool adShowing()=>_adShowing;

  bool checkFk(){
    if(null==_fengKongLogic){
      return false;
    }
    return _fengKongLogic!();
  }

  setEverydayWatchAdNum(int maxShow){
    AdNumHep.instance.setMaxShowNum(maxShow);
  }

  updateFkAdData(ConfigAdData data)async{
    if(!_hasInitSdk){
      await Future.delayed(Duration(milliseconds: 1000));
      updateFkAdData(data);
      return;
    }
    _fkPriceSwitch=data.priceSwitch;
    _fkIntLoadIosAd?.updateAdList(data.newInterList);
    _fkRvLoadIosAd?.updateAdList(data.newRewardList);
  }
}
