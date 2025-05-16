import 'package:flutter/material.dart';

class CheatSheetFilterWidget extends StatelessWidget {
  const CheatSheetFilterWidget({
    super.key,
    required this.lessonFilters,
    required this.gradeFilters,
    required this.onFilterChange,
  });

  final Map<String, bool> lessonFilters;
  final Map<String, bool> gradeFilters;
  final Function(Map<String, bool>, Map<String, bool>) onFilterChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Sınıf:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              ...gradeFilters.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${entry.key}. Sınıf'),
                    selected: entry.value,
                    onSelected: (selected) {
                      final newGradeFilters = Map<String, bool>.from(
                        gradeFilters,
                      );
                      newGradeFilters[entry.key] = selected;
                      onFilterChange(lessonFilters, newGradeFilters);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Ders:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              ...lessonFilters.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (selected) {
                      final newLessonFilters = Map<String, bool>.from(
                        lessonFilters,
                      );
                      newLessonFilters[entry.key] = selected;
                      onFilterChange(newLessonFilters, gradeFilters);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
