import 'package:flutter/material.dart';

class QuestionNavigation extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const QuestionNavigation({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: canGoBack ? onPrevious : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Önceki'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: canGoForward ? onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Sonraki'),
            style: ElevatedButton.styleFrom(
              backgroundColor: canGoForward ? Colors.blue : null,
              foregroundColor: canGoForward ? Colors.white : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
