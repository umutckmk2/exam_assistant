import 'package:flutter/material.dart';

import '../model/solved_question_model.dart';

class TopicAnalysisPage extends StatefulWidget {
  const TopicAnalysisPage({super.key, required this.solvedQuestions});

  final List<SolvedQuestionModel> solvedQuestions;

  @override
  State<TopicAnalysisPage> createState() => _TopicAnalysisPageState();
}

class _TopicAnalysisPageState extends State<TopicAnalysisPage> {
  late List<Map<String, dynamic>> _topics;
  late List<String> _topThreeStrong;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getQuestionInfo();
  }

  Future<void> _getQuestionInfo() async {
    // In a real implementation, this would process widget.solvedQuestions
    // For now, using sample data
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    _topics = [
      {
        'name': 'Paragraf',
        'correct': 8,
        'total': 10,
        'percentage': 80,
        'status': 'strong',
      },
      {
        'name': 'Üslü Sayılar',
        'correct': 7,
        'total': 8,
        'percentage': 88,
        'status': 'strong',
      },
      {
        'name': 'Canlılar Dünyası',
        'correct': 9,
        'total': 10,
        'percentage': 90,
        'status': 'strong',
      },
      {
        'name': 'Fiiller',
        'correct': 5,
        'total': 8,
        'percentage': 63,
        'status': 'developing',
      },
      {
        'name': 'Logaritma',
        'correct': 3,
        'total': 10,
        'percentage': 30,
        'status': 'critical',
      },
      {
        'name': 'Kimyasal Bağlar',
        'correct': 2,
        'total': 5,
        'percentage': 40,
        'status': 'critical',
      },
    ];

    // Get top 3 strong topics
    final strongTopics = _topics.where((t) => t['status'] == 'strong').toList();
    _topThreeStrong =
        strongTopics.take(3).map((t) => t['name'] as String).toList();

    setState(() {
      _isLoading = false;
    });
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
                    'Konu Güç Haritam',
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
              SliverToBoxAdapter(child: _buildMapLegend()),
              SliverToBoxAdapter(child: _buildMapHeader()),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildMapNode(index);
                }, childCount: _topics.length),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(
              const Color(0xFF2E7D32),
              Icons.local_fire_department,
              'Güçlü (%80+)',
            ),
            _buildLegendItem(
              const Color(0xFFFFC107),
              Icons.extension,
              'Gelişime Açık (%50-80)',
            ),
            _buildLegendItem(
              const Color(0xFFD32F2F),
              Icons.psychology,
              'Kritik Eksik (<%50)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yolculuğuna Başla',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Güçlü alanların: ${_topThreeStrong.join(", ")}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapNode(int index) {
    final topic = _topics[index];
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          // Map node connection line
          if (index > 0)
            Positioned(
              top: -8,
              left: 24,
              bottom: 0,
              child: Container(width: 3, color: Colors.grey[300]),
            ),
          // Node
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(statusIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              topic['name'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${topic['correct']}/${topic['total']} • %$percentage başarı',
                              style: const TextStyle(fontSize: 14),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Tekrar butonu işlevselliği
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Tekrar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: statusColor.withOpacity(0.1),
                                foregroundColor: statusColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
