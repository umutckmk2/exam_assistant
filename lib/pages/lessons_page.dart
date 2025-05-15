import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../service/lesson_service.dart';

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
  bool _isLoading = true;

  Future<void> _getLessons() async {
    final lessonService = LessonService(widget.categoryId);
    _lessons = await lessonService.getLessons();
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
    _getLessons();
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
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(
                  '/category/${widget.categoryId}/lessons/${lesson['id']}/topics',
                );
              },
              borderRadius: BorderRadius.circular(12),
              splashFactory: InkRipple.splashFactory,
              splashColor: Theme.of(context).primaryColor.withAlpha(25),
              highlightColor: Theme.of(context).primaryColor.withAlpha(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.book,
                            size: 32,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.topic,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${lesson['numberOfTopics']} Konu',
                                style: TextStyle(
                                  fontSize: 14,
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
            ),
          );
        },
      ),
    );
  }
}
