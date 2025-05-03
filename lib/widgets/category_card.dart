import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String id;

  const CategoryCard({super.key, required this.categoryName, required this.id});

  IconData _getIconForCategory() {
    // Use different icons based on category ID
    switch (id) {
      case '1':
        return Icons.calculate;
      case '2':
        return Icons.science;
      case '3':
        return Icons.language;
      case '4':
        return Icons.history_edu;
      case '5':
        return Icons.psychology;
      case '6':
        return Icons.public;
      case '7':
        return Icons.menu_book;
      case '8':
        return Icons.biotech;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final primaryColorLight = primaryColor.withOpacity(0.8);
    final colors = [primaryColor, primaryColorLight];
    final textColor = Colors.white;
    final icon = _getIconForCategory();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push('/category/$id/lessons');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: textColor),
                const SizedBox(height: 12),
                Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
