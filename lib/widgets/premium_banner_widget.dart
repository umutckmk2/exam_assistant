import 'package:flutter/material.dart';

import '../main.dart';
import 'banner_ad_widget.dart';

class DhAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DhAppBar({
    super.key,
    this.actions = const [],
    this.title,
    this.leading,
    this.elevation,
    this.centerTitle,
  });

  final List<Widget> actions;
  final Widget? title;
  final Widget? leading;
  final double? elevation;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    if (userNotifier.value!.isPremium) {
      return AppBar(
        title: title,
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        elevation: elevation,
      );
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
