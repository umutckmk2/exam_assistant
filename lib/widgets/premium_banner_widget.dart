import 'package:flutter/material.dart';

import '../main.dart';
import 'banner_ad_widget.dart';

class DhAppBar extends AppBar {
  DhAppBar({
    super.key,
    List<Widget> super.actions = const [],
    super.title,
    super.leading,
    super.elevation,
    super.centerTitle,
  }) : super(
         bottom:
             !userNotifier.value!.isPremium
                 ? PreferredSize(
                   preferredSize: const Size.fromHeight(60),
                   child: Padding(
                     padding: const EdgeInsets.only(bottom: 8),
                     child: BannerAdWidget(),
                   ),
                 )
                 : null,
       );

  @override
  Size get preferredSize =>
      Size.fromHeight(userNotifier.value!.isPremium ? kToolbarHeight : 120);
}
