import 'package:flutter_android_ad_plugins/hep/hep.dart';

class ToponAdInfoBean {
  ToponAdInfoBean({
      this.publisherRevenue, 
      this.publisherRevenueCny, 
      this.currency, 
      this.country, 
      this.adunitId, 
      this.precision, 
      this.networkType,});

  ToponAdInfoBean.fromJson(dynamic json) {
    publisherRevenue = json['publisher_revenue'].toString().toDouble();
    publisherRevenueCny = json['publisher_revenue_cny'].toString().toDouble();
    currency = json['currency'];
    country = json['country'];
    adunitId = json['adunit_id'];
    precision = json['precision'];
    networkType = json['network_type'];
  }
  double? publisherRevenue;
  double? publisherRevenueCny;
  String? currency;
  String? country;
  String? adunitId;
  String? precision;
  String? networkType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['publisher_revenue'] = publisherRevenue;
    map['publisher_revenue_cny'] = publisherRevenueCny;
    map['currency'] = currency;
    map['country'] = country;
    map['adunit_id'] = adunitId;
    map['precision'] = precision;
    map['network_type'] = networkType;
    return map;
  }

}