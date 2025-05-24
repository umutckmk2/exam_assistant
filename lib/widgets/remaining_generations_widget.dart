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

class _RemainingGenerationsWidgetState extends State<RemainingGenerationsWidget>
    with SingleTickerProviderStateMixin {
  final GenerationLimitService _generationLimitService =
      GenerationLimitService.instance;
  final AuthService _authService = AuthService();
  int _remainingGenerations = 0;
  bool _isPremium = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadRemainingGenerations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      // Animate when count changes
      _animationController.forward().then(
        (_) => _animationController.reverse(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final limit =
        _isPremium
            ? GenerationLimitService.premiumDailyLimit
            : GenerationLimitService.nonPremiumDailyLimit;
    final percentage = (_remainingGenerations / limit * 100).clamp(0.0, 100.0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
              _isPremium
                  ? Colors.amber.shade50
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _isPremium ? Colors.amber : Colors.grey.withAlpha(50),
            width: _isPremium ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  _isPremium
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                        color:
                            _isPremium ? Colors.amber[700] : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '$_remainingGenerations/$limit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _isPremium ? Colors.amber[900] : Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor:
                    _isPremium
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isPremium ? Colors.amber : Colors.grey,
                ),
                minHeight: 4,
              ),
            ),
            if (!_isPremium) ...[
              const SizedBox(height: 8),
              Text(
                'Premium ile günlük 50 üretim hakkı',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
