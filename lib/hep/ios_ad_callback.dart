import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_android_ad_plugins/data/ad_money_info_bean.dart';

class IosAdCallback{
  Function(AdMoneyInfoBean? ad,AdInfoData? bean) showSuccess;
  Function() showFail;
  Function(AdMoneyInfoBean? ad,AdInfoData? bean,bool hasReward) closeAd;
  Function(AdMoneyInfoBean? ad,AdInfoData? bean) revenuePaid;

  IosAdCallback({
    required this.showSuccess,
    required this.showFail,
    required this.closeAd,
    required this.revenuePaid,
  });
}