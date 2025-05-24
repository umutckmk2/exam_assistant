import 'package:flutter/material.dart';

import '../main.dart';
import 'banner_ad_widget.dart';

class PremiumBannerWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const PremiumBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (userNotifier.value!.isPremium) {
      return const SizedBox.shrink();
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BannerAdWidget(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
