import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../service/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    final bannerAd = await AdService.instance.loadBannerAd(
      size: widget.adSize,
      onAdLoaded: (ad) {
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (error) {
        debugPrint('Banner ad failed to load: ${error.message}');
        setState(() {
          _isLoaded = false;
        });
      },
    );

    setState(() {
      _bannerAd = bannerAd;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) {
      return SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
