import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class Monetization {
  static BannerAd loadNewBanner() {
    String id = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
    return BannerAd(
      adUnitId: id,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load.');
          ad.dispose();
        },
      ),
    )..load();
  }

  static Completer<InterstitialAd?> loadNewInterstitial() {
    String id = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
    Completer<InterstitialAd?> c = Completer();
    InterstitialAd.load(
        adUnitId: id,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
              },
            );
            c.complete(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load.');
          },
        ));
    return c;
  }
}
