class AdMoneyInfoBean{
  String adUnitId;
  double revenue;
  String networkName;
  String revenuePrecision;
  AdMoneyInfoBean({
    required this.adUnitId,
    required this.revenue,
    required this.networkName,
    required this.revenuePrecision,
});

  @override
  String toString() {
    return 'AdMoneyInfoBean{adUnitId: $adUnitId, revenue: $revenue, networkName: $networkName, revenuePrecision: $revenuePrecision}';
  }
}