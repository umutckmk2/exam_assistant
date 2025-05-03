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
