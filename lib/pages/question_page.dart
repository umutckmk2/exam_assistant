import 'package:flutter/material.dart';

import '../service/topic_service.dart';

class QuestionPage extends StatefulWidget {
  final String topicId;
  final String lessonId;
  final String categoryId;

  const QuestionPage({
    super.key,
    required this.topicId,
    required this.lessonId,
    required this.categoryId,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Map? _topic;
  bool _isLoading = true;

  Future<void> _getTopic() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    _topic = await topicService.getTopic(widget.topicId);

    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getTopic();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topicId),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
              tooltip: 'Yeni Soru',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sınav için aşağıdaki butona tıklayın:'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
