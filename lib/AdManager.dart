import 'package:firebase_admob/firebase_admob.dart';

const List<String> testDevices = ['8F295EE19D724BC9954CFBFA606EC171'];

class AdManager {
  static BannerAd _bannerAd;

  static void initializeAd() {
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  static BannerAd _createBannerAd() {
    return BannerAd(
        adUnitId: AdManager.bannerAdUnitId,
        size: AdSize.banner,
        targetingInfo: MobileAdTargetingInfo(testDevices: testDevices));
  }

  static void showBannerAd() {
    if (_bannerAd == null) _bannerAd = _createBannerAd();
    _bannerAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  static void hideBannerAd() async {
    await _bannerAd.dispose();
    _bannerAd = null;
  }

  static String get appId {
    return "ca-app-pub-8854156000502748~5072564408";
  }

  static String get bannerAdUnitId {
    return "ca-app-pub-8854156000502748/9830244674";
  }
}
