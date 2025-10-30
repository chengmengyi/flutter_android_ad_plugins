import 'package:flutter_android_ad_plugins/hep/ad_type.dart';

class AdInfoData{
  String adId;
  String adPlat;
  AdType adType;
  int expireTime;
  // int sort;
  AdInfoData({
    required this.adId,
    required this.adPlat,
    required this.adType,
    required this.expireTime,
    // required this.sort,
  });

  @override
  String toString() {
    return 'AdInfoData{adId: $adId, adPlat: $adPlat, adType: $adType, expireTime: $expireTime}';
  }
}