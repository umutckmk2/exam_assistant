import 'package:flutter/material.dart';

class DailyGoalPercentageWidget extends StatelessWidget {
  const DailyGoalPercentageWidget({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.color,
  });

  final String title;
  final String value;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white.withAlpha(225),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withAlpha(50),
              color: color,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
