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
          child: const CircularProgressIndicator(
            color: Colors.blue,
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
              icon: const Icon(Icons.account_circle, color: Colors.green),
              onPressed: () {
                context.push('/account');
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DailyGoalsWidget(),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _categories!.length,
                  itemBuilder: (__, i) {
                    return CategoryCard(
                      categoryName: _categories![i]['name'],
                      id: _categories![i]['id'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
