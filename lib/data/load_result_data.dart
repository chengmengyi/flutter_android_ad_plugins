import 'package:flutter_android_ad_plugins/data/ad_info_data.dart';

class LoadResultData{
  int loadTime;
  AdInfoData adBean;
  double revenue;

  LoadResultData({
    required this.loadTime,
    required this.adBean,
    required this.revenue,
  });
}