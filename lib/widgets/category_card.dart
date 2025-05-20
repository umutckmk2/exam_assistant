import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final primaryColorLight = primaryColor.withAlpha(200);
    final colors = [primaryColor, primaryColorLight];
    final textColor = Colors.white;
    final icon = _getIconForCategory();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add a small haptic feedback before navigation
            HapticFeedback.lightImpact();

            // Use push for smooth navigation with transitions
            context.push('/category/$id/lessons');
          },
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.white.withAlpha(75),
          highlightColor: Colors.white.withAlpha(25),
          child: Hero(
            tag: 'category_$id',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24, color: textColor),
                    const SizedBox(height: 6),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
