import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LimitExceededDialog extends StatelessWidget {
  final bool isPremium;
  final int remainingGenerations;
  final int dailyLimit;

  const LimitExceededDialog({
    super.key,
    required this.isPremium,
    required this.remainingGenerations,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isPremium
                        ? const Color(0xFFFFD700)
                        : Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPremium ? Icons.star : Icons.warning_rounded,
                size: 32,
                color: isPremium ? Colors.white : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPremium ? 'Premium Limit' : 'Günlük Limit',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPremium
                  ? 'Premium kullanıcı olarak günlük $dailyLimit AI üretim hakkınız bulunmaktadır.'
                  : 'Ücretsiz kullanıcı olarak günlük $dailyLimit AI üretim hakkınız bulunmaktadır.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              'Kalan Hakkınız: $remainingGenerations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: remainingGenerations > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            if (!isPremium)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/premium');
                },
                icon: const Icon(Icons.star, color: Color(0xFFFFD700)),
                label: const Text("Premium'a Yükselt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
          ],
        ),
      ),
    );
  }
}
