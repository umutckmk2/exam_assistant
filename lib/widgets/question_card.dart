import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuestionCard extends StatelessWidget {
  final String questionHtml;

  const QuestionCard({super.key, required this.questionHtml});

  @override
  Widget build(BuildContext context) {
    // Convert simple HTML to Markdown for display
    final String questionText = questionHtml
        .replaceAll(RegExp(r'<p>|</p>'), '')
        .replaceAll('<br>', '\n')
        .replaceAll('&nbsp;', ' ');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (questionHtml.contains('<img'))
              Center(
                child: Text(
                  '[Bu soruda resim bulunmaktadır]',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Markdown(
              data: questionText,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
