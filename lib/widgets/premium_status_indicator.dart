import 'package:flutter/material.dart';

import '../main.dart';

class PremiumStatusIndicator extends StatelessWidget {
  const PremiumStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = userNotifier.value?.isPremium ?? false;

    if (!isPremium) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFFFFD700)),
          const SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }
}
