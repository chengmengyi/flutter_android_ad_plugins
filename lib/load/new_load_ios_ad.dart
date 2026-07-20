import 'package:flutter_android_ad_plugins/data/ad_money_info_bean.dart';
import 'package:flutter_android_ad_plugins/flutter_android_ad_plugins.dart';
import 'package:flutter_android_ad_plugins/hep/ad_type.dart';
import 'package:flutter_android_ad_plugins/hep/hep.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_android_ad_plugins/data/load_result_data.dart';
import 'package:flutter_android_ad_plugins/hep/ad_num_hep.dart';
import 'package:flutter_android_ad_plugins/hep/ios_load_ad_result_callback.dart';
import 'package:thinkup_sdk/at_interstitial.dart';
import 'package:thinkup_sdk/at_rewarded.dart';

///新版加载广告
class NewLoadIosAd {
  bool interAd;
  final List<AdInfoData> _adInfoList = [];
  final Map<String, AdInfoData> _loadingMap = {};
  final Map<String, LoadResultData> _resultMap = {};
  final Map<String, int> _loadAdStartTimeMap = {};
  IosLoadAdResultCallback iosLoadAdResultCallback;

  NewLoadIosAd({required this.interAd, required this.iosLoadAdResultCallback});

  loadAllAd() {
    if (_adInfoList.isEmpty) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->list is empty"
          .log();
      return;
    }
    if (AdNumHep.instance.notLoad()) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->show or click max, not load ad"
          .log();
      return;
    }
    for (var value in _adInfoList) {
      var result = loadAdById(value);
      if (!result) {
        continue;
      }
    }
  }

  bool loadAdById(AdInfoData value) {
    if (FlutterAndroidAdPlugins.instance.checkFk()) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->fengkong not load ad"
          .log();
      return false;
    }
    var indexWhere = _adInfoList.indexWhere(
      (element) => element.adId == value.adId,
    );
    if (indexWhere < 0) {
      return false;
    }
    if (_loadingMap.containsKey(value.adId)) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->${value.adId} is loading"
          .log();
      return false;
    }
    if (checkHasCache(value.adId)) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->${value.adId} has cache"
          .log();
      return false;
    }
    _loadingMap[value.adId] = value;
    "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->start load ${value.adId} ,info=>${value.toString()}"
        .log();
    _loadAdStartTimeMap[value.adId] = DateTime.now().millisecondsSinceEpoch;
    if (value.adType == AdType.reward) {
      iosLoadAdResultCallback.startLoadAdCallback.call(value);
      switch (value.adPlat) {
        case "max":
          AppLovinMAX.loadRewardedAd(value.adId);
          break;
        case "topon":
          ATRewardedManager.loadRewardedVideo(
            placementID: value.adId,
            extraMap: {
              // ATSplashManager.tolerateTimeout(): 20000,
              ATRewardedManager.kATAdLoadingExtraUserIDKey(): '1234',
            },
          );
          break;
        default:
          _loadingMap.remove(value.adId);
          break;
      }
    } else if (value.adType == AdType.interstitial) {
      iosLoadAdResultCallback.startLoadAdCallback.call(value);
      switch (value.adPlat) {
        case "max":
          AppLovinMAX.loadInterstitial(value.adId);
          break;
        case "topon":
          ATInterstitialManager.loadInterstitialAd(
            placementID: value.adId,
            extraMap: {
              // ATSplashManager.tolerateTimeout(): 20000
            },
          );
          break;
        default:
          _loadingMap.remove(value.adId);
          break;
      }
    } else {
      _loadingMap.remove(value.adId);
    }
    return true;
  }

  loadAdSuccess(AdMoneyInfoBean ad) {
    var adBean =
        _loadingMap.remove(ad.adUnitId) ?? getAdInfoBeanById(ad.adUnitId);
    if (null != adBean) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->${ad.adUnitId} load ad success--->revenue:${ad.revenue}"
          .log();
      var startTime = _loadAdStartTimeMap[ad.adUnitId] ?? 0;
      var loadTime = 0;
      if (startTime != 0) {
        loadTime = DateTime.now().millisecondsSinceEpoch - startTime;
      }
      iosLoadAdResultCallback.loadAdSuccessCallback.call(ad, adBean, loadTime);
      _resultMap[adBean.adId] = LoadResultData(
        loadTime: DateTime.now().millisecondsSinceEpoch,
        adBean: adBean,
        revenue: ad.revenue,
      );
    }
  }

  loadAdFail(String id, String failReason) async {
    var adBean = _loadingMap.remove(id) ?? getAdInfoBeanById(id);
    if (null != adBean) {
      "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->$id load ad fail--->failReason:$failReason"
          .log();
      iosLoadAdResultCallback.loadAdFailCallback.call(adBean, failReason);
      await Future.delayed(Duration(milliseconds: 1000));
      loadAdById(adBean);
    }
  }

  AdInfoData? getAdInfoBeanById(String id) {
    var indexWhere = _adInfoList.indexWhere((value) => value.adId == id);
    if (indexWhere >= 0) {
      return _adInfoList[indexWhere];
    }
    return null;
  }

  bool checkHasCache(String adId) {
    var bean = _resultMap[adId];
    if (null != bean) {
      var expired =
          (DateTime.now().millisecondsSinceEpoch - bean.loadTime) >
          bean.adBean.expireTime * 1000;
      if (expired) {
        deleteCache(bean.adBean.adId);
        return false;
      }
      return true;
    }
    return false;
  }

  LoadResultData? getCashAd() {
    List<LoadResultData> list = [];
    for (var value in _resultMap.keys) {
      var data = _resultMap[value];
      if (null != data && checkHasCache(data.adBean.adId)) {
        list.add(data);
      }
    }
    if (list.isEmpty) {
      return null;
    }
    list.sort((a, b) => (b.revenue).compareTo(a.revenue));
    return list.first;
  }

  List<LoadResultData> getHasCacheResultList() {
    List<LoadResultData> list = [];
    for (var value in _resultMap.keys) {
      var data = _resultMap[value];
      if (null != data && checkHasCache(data.adBean.adId)) {
        list.add(data);
      }
    }
    return list;
  }

  deleteCache(String? adId) {
    _resultMap.removeWhere((key, value) => value.adBean.adId == adId);
  }

  updateAdList(List<AdInfoData> adInfoList) {
    "flutter ios ad --->${interAd ? "inter ad" : "rv ad"}--->update ad list ---> adInfoList--->$adInfoList"
        .log();
    _adInfoList.clear();
    // adInfoList.sort((a, b) => (b.sort).compareTo(a.sort));
    _adInfoList.addAll(adInfoList);
    loadAllAd();
  }
}
