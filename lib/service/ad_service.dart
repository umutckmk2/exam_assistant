import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() => _instance;
  static AdService get instance => _instance;

  AdService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Test ad unit IDs
  final Map<String, String> _testAdUnitIds = {
    'banner':
        Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-3940256099942544/2934735716',
    'interstitial':
        Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
  };

  // Production ad unit IDs - these would be replaced with actual production IDs
  final Map<String, String> _productionAdUnitIds = {
    'banner':
        Platform.isAndroid
            ? 'ca-app-pub-5309874269430815/9861859757' // Replace with actual production ID
            : 'ca-app-pub-XXXXX/XXXXX', // Replace with actual production ID
    'interstitial':
        Platform.isAndroid
            ? 'ca-app-pub-5309874269430815/7235696418' // Replace with actual production ID
            : 'ca-app-pub-XXXXX/XXXXX', // Replace with actual production ID
  };

  // Use test ads during development
  final bool _useTestAds = true;

  // Get ad unit ID based on ad type
  String getAdUnitId(String adType) {
    final adUnitIds = _useTestAds ? _testAdUnitIds : _productionAdUnitIds;
    return adUnitIds[adType] ?? '';
  }

  // Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();

    // Set ad request configurations if needed
    // For example, setting tag for child-directed treatment
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        testDeviceIds: ['kGADSimulatorID'], // Test device IDs
      ),
    );

    _isInitialized = true;
  }

  // Load and return a banner ad
  Future<BannerAd?> loadBannerAd({
    AdSize size = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();

    final bannerAd = BannerAd(
      adUnitId: getAdUnitId('banner'),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad(error);
          }
        },
      ),
    );

    try {
      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      return null;
    }
  }

  // Load and show an interstitial ad
  Future<InterstitialAd?> loadInterstitialAd({
    void Function(Ad)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
    void Function()? onAdDismissedFullScreen,
  }) async {
    if (!_isInitialized) await initialize();

    InterstitialAd? interstitialAd;

    try {
      await InterstitialAd.load(
        adUnitId: getAdUnitId('interstitial'),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
            if (onAdLoaded != null) {
              onAdLoaded(ad);
            }
          },
          onAdFailedToLoad: (error) {
            if (onAdFailedToLoad != null) {
              onAdFailedToLoad(error);
            }
          },
        ),
      );

      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            if (onAdDismissedFullScreen != null) {
              onAdDismissedFullScreen();
            }
          },
        );
      }

      return interstitialAd;
    } catch (e) {
      return null;
    }
  }
}
