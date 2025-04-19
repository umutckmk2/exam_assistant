import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/question_model.dart';
import '../service/question_service.dart';
import '../widgets/topic_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Question>? _questions;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _topics = [
    "Türkçe",
    "Matematik",
    "Geometri",
    "Sözel Mantık",
    "Sayısal Mantık",
    "Genel Kültür Deneme",
    "Tarih",
    "Coğrafya",
    "Vatandaşlık",
  ];

  Future<void> _loadQuestions() async {
    final questions = await QuestionService.instance.loadQuestions();
    _questions = questions;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text('KPSS AI Asistan'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'KPSS AI Asistan',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Ana Sayfa'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Hesabım'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/account');
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('AI Konu Özetlerim'),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('İstatistikler'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/statistics');
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              return TopicCard(topic: _topics[index]);
            },
          ),
        ),
      ),
    );
  }
}
