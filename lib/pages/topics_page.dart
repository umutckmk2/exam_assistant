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
  bool _isLoading = true;

  Future<void> _getTopics() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    final topics = await topicService.getTopics();
    _topics = topics;
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  context.push(
                    '/question/${widget.categoryId}/${widget.lessonId}/${topic['id']}',
                  );
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
                          ).primaryColor.withOpacity(0.2),
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
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }(),
    );
  }
}
