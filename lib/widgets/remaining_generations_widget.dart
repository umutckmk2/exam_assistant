import 'package:flutter/material.dart';

import '../main.dart';
import '../service/auth_service.dart';
import '../service/generation_limit_service.dart';

class RemainingGenerationsWidget extends StatefulWidget {
  const RemainingGenerationsWidget({super.key});

  @override
  State<RemainingGenerationsWidget> createState() =>
      _RemainingGenerationsWidgetState();
}

class _RemainingGenerationsWidgetState
    extends State<RemainingGenerationsWidget> {
  final GenerationLimitService _generationLimitService =
      GenerationLimitService.instance;
  final AuthService _authService = AuthService();
  int _remainingGenerations = 0;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadRemainingGenerations();
  }

  Future<void> _loadRemainingGenerations() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final remaining = await _generationLimitService.getRemainingGenerations(
      userId,
    );
    final isPremium = userNotifier.value?.isPremium ?? false;

    if (mounted) {
      setState(() {
        _remainingGenerations = remaining;
        _isPremium = isPremium;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color:
            _isPremium ? Colors.amber.withAlpha(25) : Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: _isPremium ? Colors.amber : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kalan AI Üretimi',
                style: TextStyle(
                  fontSize: 12,
                  color: _isPremium ? Colors.amber[700] : Colors.grey[700],
                ),
              ),
              Text(
                '$_remainingGenerations/${_isPremium ? GenerationLimitService.premiumDailyLimit : GenerationLimitService.nonPremiumDailyLimit}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isPremium ? Colors.amber[900] : Colors.grey[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
