import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/auth_service.dart';
import '../service/user_service.dart';
import '../widgets/category_card.dart';
import '../widgets/daily_goals_widget.dart';
import '../widgets/premium_banner_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authService = AuthService();

  List<Map>? _categories;

  Future<void> _getCategories() async {
    final qs = await FirebaseFirestore.instance.collection('category').get();

    for (final doc in qs.docs) {
      _categories ??= [];
      _categories!.add({"id": doc.id, ...doc.data()});
    }

    _categories!.sort(
      (a, b) => int.tryParse(a['id'])!.compareTo(int.tryParse(b['id'])!),
    );

    if (mounted) setState(() {});
  }

  Future<void> _signOut() async {
    context.go('/');
    UserService.instance.deleteUser(_authService.currentUser?.uid ?? '');
    AuthService().signOut();
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) {
      return Scaffold(
        appBar: DhAppBar(title: const Text('YKS Asistan')),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 5,
          ),
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: DhAppBar(title: const Text('YKS Asistan')),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withAlpha(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(225),
                          ),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.school,
                              size: 32,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YKS Asistan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _authService.currentUser?.email ??
                                    'Misafir Kullanıcı',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(225),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: const Text('Ana Sayfa'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.book, color: Colors.purple),
                      title: const Text('AI Konu Özetlerim'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/cheat-sheets');
                      },
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(
                        Icons.bar_chart,
                        color: Colors.orange,
                      ),
                      title: const Text('İstatistikler'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/statistics');
                      },
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: Icon(
                        Icons.question_answer,
                        color: Colors.green.shade300,
                      ),
                      title: const Text('Soru Sor'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/ask-question');
                      },
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: const Text('Premium Üyelik'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/premium');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.teal),
                      title: const Text('Soru Geçmişim'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/question-history');
                      },
                    ),
                    const Divider(height: 1, indent: 70),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Başarıya giden yolda bizimle çalışmaya devam edin!',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Çıkış Yap'),
                onTap: _signOut,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/ask-question'),
          backgroundColor: Theme.of(context).primaryColor,
          icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          label: const Text(
            'Soru Sor',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          tooltip: 'Soru Sor',
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(12),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Merhaba, YKS Asistan'a hoş geldiniz!",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "AI ile konularınızı pekiştirin!, Sorularınızı sorun ve cevaplayın!",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 4; i++)
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48) / 4,
                            child: CategoryCard(
                              categoryName: _categories![i]['name'],
                              id: _categories![i]['id'],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const DailyGoalsWidget(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
