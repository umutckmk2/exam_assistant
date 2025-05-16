import 'package:flutter/material.dart';

import '../model/solved_question_model.dart';
import '../service/topic_service.dart';
import '../widgets/statistics/map_legend_widget.dart';

class TopicAnalysisPage extends StatefulWidget {
  const TopicAnalysisPage({super.key, required this.solvedQuestions});

  final List<SolvedQuestionModel> solvedQuestions;

  @override
  State<TopicAnalysisPage> createState() => _TopicAnalysisPageState();
}

class _TopicAnalysisPageState extends State<TopicAnalysisPage> {
  Map<String, Map<String, List<Map<String, dynamic>>>> _groupedTopics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getTopics();
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

  Future<void> _getTopics() async {
    _isLoading = true;
    setState(() {});

    final categories =
        widget.solvedQuestions.map((question) => question.category).toSet();
    for (final category in categories) {
      final categoryQuestions =
          widget.solvedQuestions
              .where((question) => question.category == category)
              .toList();
      final lessons =
          categoryQuestions.map((question) => question.lesson).toSet();
      _groupedTopics[category] = {};
      for (final lesson in lessons) {
        final lessonQuestions =
            categoryQuestions
                .where((question) => question.lesson == lesson)
                .toList();
        final topics =
            lessonQuestions.map((question) => question.topicNumber).toSet();
        _groupedTopics[category]![_lessonNames[lesson] ?? lesson] = [];
        for (final topicNumber in topics) {
          final questions =
              lessonQuestions
                  .where((question) => question.topicNumber == topicNumber)
                  .toList();

          final correct =
              questions.where((question) => question.isCorrect).length;

          final total = questions.length;
          final percentage = (correct / total * 100).toInt();

          final topic = await TopicService.instance.getTopic(
            topicNumber,
            category,
            lesson,
          );

          final lessonName = _lessonNames[lesson] ?? lesson;
          final topicData = {
            'name': topic['topic'],
            'lesson': lessonName,
            'grade': category,
            'correct': correct,
            'total': total,
            'percentage': percentage,
            'status':
                percentage >= 80
                    ? 'strong'
                    : percentage >= 50
                    ? 'developing'
                    : 'critical',
          };

          _groupedTopics[category]![_lessonNames[lesson] ?? lesson]!.add(
            topicData,
          );
        }
      }
    }

    // Sort categories to follow 9,10,11,12 order
    _groupedTopics = Map.fromEntries(
      ['9', '10', '11', '12']
          .where((grade) => _groupedTopics.containsKey(grade))
          .map((grade) => MapEntry(grade, _groupedTopics[grade]!)),
    );
    _isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.map, size: 28, color: Color(0xFF4C9F70)),
                  const SizedBox(width: 8),
                  const Text(
                    'Güç Haritam',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Nerede Güçlüsün, Nerede Gelişmelisin?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: MapLegendWidget()),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, gradeIndex) {
                  final grade = _groupedTopics.keys.elementAt(gradeIndex);
                  final lessonMap = _groupedTopics[grade]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '$grade. Sınıf',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C9F70),
                          ),
                        ),
                      ),
                      ...lessonMap.entries.map((lessonEntry) {
                        final lessonName = lessonEntry.key;
                        final topics = lessonEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                lessonName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ...topics.map((topic) => _buildTopicCard(topic)),
                          ],
                        );
                      }),
                    ],
                  );
                }, childCount: _groupedTopics.length),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final status = topic['status'] as String;
    final percentage = topic['percentage'] as int;

    // Set icon and color based on status
    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (status == 'strong') {
      statusIcon = Icons.local_fire_department;
      statusColor = const Color(0xFF2E7D32);
      statusText = 'Güçlü';
    } else if (status == 'developing') {
      statusIcon = Icons.extension;
      statusColor = const Color(0xFFFFC107);
      statusText = 'Gelişime Açık';
    } else {
      statusIcon = Icons.psychology;
      statusColor = const Color(0xFFD32F2F);
      statusText = 'Kritik Eksik';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${topic['correct']}/${topic['total']} • %$percentage başarı',
                    style: const TextStyle(fontSize: 12),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Tekrar', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor.withOpacity(0.1),
                      foregroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
