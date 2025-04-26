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
        title: Text(widget.lessonId),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
      itemCount: _topics!.length,
      itemBuilder: (__, i) => ListTile(title: Text(_topics![i]['topic'])),
    );
  }
}
