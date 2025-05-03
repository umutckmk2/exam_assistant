import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/topic_service.dart';

class TopicsPage extends StatefulWidget {
  final String categoryId;
  final String lessonId;

  const TopicsPage({
    super.key,
    required this.categoryId,
    required this.lessonId,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Map>? _topics;
  final Map<String, bool> _expandedTopics = {};
  bool _isLoading = true;

  Future<void> _getTopics() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    final topics = await topicService.getTopics();
    _topics = topics;

    // Initialize expanded state for all topics
    for (var topic in topics) {
      _expandedTopics[topic['id']] = false;
    }

    _isLoading = false;
    setState(() {});
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
    _getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lessonNames[widget.lessonId] ?? ''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: () {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_topics == null || _topics!.isEmpty) {
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _topics!.length,
          itemBuilder: (context, index) {
            final topic = _topics![index];
            final String topicId = topic['id'];
            final bool isExpanded = _expandedTopics[topicId] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Main topic header
                  InkWell(
                    onTap: () {
                      _expandedTopics[topicId] = !isExpanded;
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withAlpha(51),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic['topic'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Navigate to question page with this topic
                                  context.push(
                                    '/category/${widget.categoryId}/lessons/${widget.lessonId}/topics/$topicId/null',
                                  );
                                },
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).primaryColor,
                                ),
                                tooltip: 'Bu konuya git',
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isExpanded)
                    if (topic['subTopics'] == null ||
                        topic['subTopics']!.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Bu konuya ait alt başlık bulunamadı.'),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: topic['subTopics']!.length,
                          itemBuilder: (context, index) {
                            final subtopic = topic['subTopics']![index];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              color: Theme.of(
                                context,
                              ).primaryColor.withAlpha(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade50),
                              ),
                              child: ListTile(
                                onTap: () {
                                  context.push(
                                    '/category/${widget.categoryId}/lessons/${widget.lessonId}/topics/$topicId/${subtopic['value']}',
                                  );
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.school_outlined,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  (subtopic['text'] ?? '')
                                      .split('.-')
                                      .last
                                      .trim(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
            );
          },
        );
      }(),
    );
  }
}
