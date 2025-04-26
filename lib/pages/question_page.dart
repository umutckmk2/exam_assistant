import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../service/topic_service.dart';
import 'web_view_page.dart';

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
  String examUrl =
      'https://ogmmateryal.eba.gov.tr/soru-bankasi/matematik/test?s=9&d=0&u=0&k=2862&id=5959,5961,5963,5968,5972,23383,23384,23385,23386,23387&p=1&t=css&ks=0&os=0&zs=0';

  Future<void> _getTopic() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    final topic = await topicService.getTopic(widget.topicId);

    _getTopicUrlsFromAssets(topic);

    _topic = topic;
    _isLoading = false;
    setState(() {});
  }

  Future<void> _getTopicUrlsFromAssets(Map topic) async {
    final topicUrlsFromAssets = await rootBundle.loadString(
      'assets/topics_questions.json',
    );
    final topicUrls = jsonDecode(topicUrlsFromAssets) as Map;

    print("topicUrls: ${widget.topicId}");

    var questionIds = [];

    var subTopicIds = [];

    for (final url in topicUrls.keys) {
      final id = url.split('id=').last;

      if (topic['subTopicIds'] == null || topic['subTopicIds'].isEmpty) {
        continue;
      }

      for (final topic in topic['subTopicIds']) {
        if (topic == id) {
          final questions = topicUrls[url]['questions'];
          for (final question in questions) {
            if (question['cevap'] < 6) {
              questionIds.add(question['id']);
            }
          }
        }
      }
    }

    examUrl =
        "https://ogmmateryal.eba.gov.tr/soru-bankasi/${widget.lessonId}/test?s=${int.tryParse(widget.categoryId)! - 3}&u=0&k=${topic['subTopicIds'].join(',')}&id=${questionIds.join(',')}&t=css&ks=0&os=0&zs=0";
    print("examUrl: $examUrl");
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WebViewPage(
                            url: examUrl,
                            title: 'EBA Soru Bankası',
                          ),
                    ),
                  );
                },
                child: const Text('Sınavı Başlat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
