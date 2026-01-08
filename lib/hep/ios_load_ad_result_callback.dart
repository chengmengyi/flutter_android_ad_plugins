import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_android_ad_plugins/data/ad_money_info_bean.dart';
class IosLoadAdResultCallback{
  Function(AdInfoData? bean) startLoadAdCallback;
  Function(AdMoneyInfoBean adMoneyInfoBean,AdInfoData? bean,int loadTime) loadAdSuccessCallback;
  Function(AdInfoData? bean,String failReason) loadAdFailCallback;
  Function(int time,String platForm) initSdkSuccess;

  IosLoadAdResultCallback({
    required this.startLoadAdCallback,
    required this.loadAdSuccessCallback,
    required this.loadAdFailCallback,
    required this.initSdkSuccess,
  });
}