import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';

class ConfigAdData{
  int maxShowNum;
  int maxClickNum;
  bool priceSwitch;
  List<AdInfoData> newInterList; //新方案插屏list
  List<AdInfoData> newRewardList; //新方案激励list
  ConfigAdData({
    required this.maxShowNum,
    required this.maxClickNum,
    required this.priceSwitch,
    required this.newInterList,
    required this.newRewardList,
  });
}