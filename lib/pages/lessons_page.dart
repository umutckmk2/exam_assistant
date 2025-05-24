import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../service/lesson_service.dart';
import '../service/topic_service.dart';

class LessonsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const LessonsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage>
    with SingleTickerProviderStateMixin {
  List<Map>? _lessons;
  Map<String, List<Map>>? _topics;
  final Map<String, bool> _expandedLessons = {};
  bool _isLoading = true;

  Future<void> _getLessonsAndTopics() async {
    final lessonService = LessonService(widget.categoryId);
    _lessons = await lessonService.getLessons();

    // Initialize topics map
    _topics = {};
    for (var lesson in _lessons!) {
      _expandedLessons[lesson['id']] = false;
      final topicService = TopicService.instance;
      final topics = await topicService.getTopics(
        widget.categoryId,
        lesson['id'],
      );
      _topics![lesson['id']] = topics;
    }

    _isLoading = false;
    if (mounted) setState(() {});
  }

  final _lessonNames = {
    "dikab": "Din Kültürü ve Ahlak Bilgisi",
    "tde": "Türk Dili ve Edebiyatı",
    "biyoloji": "Biyoloji",
    "kimya": "Kimya",
    "fizik": "Fizik",
    "cografya": "Coğrafya",
    "felsefe": "Felsefe",
    "fl-biyoloji": "Fen Lisesi Biyoloji",
    "fl-kimya": "Fen Lisesi Kimya",
    "fl-fizik": "Fen Lisesi Fizik",
    "fl-matematik": "Fen Lisesi Matematik",
    "ingilizce": "İngilizce",
    "tarih": "Tarih",
    "matematik": "Matematik",
    "inkilap-tarihi": "İnkılâp Tarihi",
  };

  @override
  void initState() {
    super.initState();
    _getLessonsAndTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Add haptic feedback when going back
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: Material(
        // Use a Material widget to wrap the content
        color: Colors.transparent,
        child: Hero(
          tag: 'category_${widget.categoryId}',
          child: Material(color: Colors.transparent, child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lessons == null || _lessons!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Bu kategoride ders bulunmamaktadır',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _lessons!.length,
        itemBuilder: (__, i) {
          final lesson = _lessons![i];
          final isExpanded = _expandedLessons[lesson['id']] ?? false;
          final topics = _topics![lesson['id']] ?? [];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _expandedLessons[lesson['id']] = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashFactory: InkRipple.splashFactory,
                  splashColor: Theme.of(context).primaryColor.withAlpha(25),
                  highlightColor: Theme.of(context).primaryColor.withAlpha(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.book,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lessonNames[lesson['id']] ?? lesson['id'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.topic,
                                          size: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${topics.length} Konu',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement test generation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Test oluşturma yakında!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.assignment,
                            color: Theme.of(context).primaryColor,
                          ),
                          tooltip: 'Test Oluştur',
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const Divider(height: 1),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return ListTile(
                        dense: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push(
                            '/category/${widget.categoryId}/lessons/${lesson['id']}/questions/${topic['id']}/null',
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          topic['topic'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
