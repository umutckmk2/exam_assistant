import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/category_card.dart';
import '../widgets/daily_goals_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('YKS Asistan')),
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
        appBar: AppBar(
          title: const Text('YKS Asistan'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                context.push('/account');
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.school, size: 35, color: Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'YKS Asistan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sınava Hazırlanmanın En Kolay Yolu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
                leading: const Icon(Icons.account_circle, color: Colors.green),
                title: const Text('Hesabım'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/account');
                },
              ),
              const Divider(height: 1, indent: 70),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.purple),
                title: const Text('AI Konu Özetlerim'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation logic here
                },
              ),
              const Divider(height: 1, indent: 70),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.orange),
                title: const Text('İstatistikler'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/statistics');
                },
              ),
              const Divider(height: 1, indent: 70),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate grid dimensions
                    final int crossAxisCount = 2;
                    final double spacing = 16.0;
                    final double aspectRatio = 1.2;

                    // Calculate rows needed
                    final int rowCount =
                        (_categories!.length / crossAxisCount).ceil();

                    // Calculate item dimensions
                    final double itemWidth =
                        (constraints.maxWidth - spacing) / crossAxisCount;
                    final double itemHeight = itemWidth / aspectRatio;

                    // Total height for grid
                    final double gridHeight =
                        (itemHeight * rowCount) + (spacing * (rowCount - 1));

                    return SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: _categories!.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            categoryName: _categories![index]['name'],
                            id: _categories![index]['id'],
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      "Günlük Hedefler",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const DailyGoalsWidget(),
                const SizedBox(height: 16), // Add padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
