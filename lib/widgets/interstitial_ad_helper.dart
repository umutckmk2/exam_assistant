import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../service/ad_service.dart';

class InterstitialAdHelper {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  // Singleton instance
  static final InterstitialAdHelper _instance =
      InterstitialAdHelper._internal();
  factory InterstitialAdHelper() => _instance;
  InterstitialAdHelper._internal();

  // Get singleton instance
  static InterstitialAdHelper get instance => _instance;

  bool get isAdLoaded => _isAdLoaded;
  bool get isAdShowing => _isAdShowing;

  // Load an interstitial ad
  Future<void> loadAd() async {
    if (_isAdLoaded || _isAdShowing) return;

    try {
      _interstitialAd = await AdService.instance.loadInterstitialAd(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          debugPrint('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          debugPrint('Failed to load interstitial ad: ${error.message}');
        },
        onAdDismissedFullScreen: () {
          _isAdShowing = false;
          _isAdLoaded = false;
          _interstitialAd = null;
          // Load a new ad after the current one is dismissed
          loadAd();
        },
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
    }
  }

  // Show the loaded interstitial ad
  Future<bool> showAd() async {
    if (!_isAdLoaded || _interstitialAd == null || _isAdShowing) {
      return false;
    }

    try {
      _isAdShowing = true;
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      _isAdShowing = false;
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  // Show an interstitial ad with a probability factor (0.0 to 1.0)
  // This is useful for controlling how often ads are shown
  Future<bool> showAdWithProbability(double probability) async {
    if (probability <= 0) return false;
    if (probability >= 1 ||
        (probability > 0 &&
            probability >=
                (DateTime.now().millisecondsSinceEpoch % 100) / 100)) {
      return await showAd();
    }
    return false;
  }

  // Dispose the ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isAdShowing = false;
  }
}
