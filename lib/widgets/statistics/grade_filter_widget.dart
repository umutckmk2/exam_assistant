import 'package:flutter/material.dart';

import 'filter_dialog.dart';

class GradeFilterWidget extends StatefulWidget {
  const GradeFilterWidget({
    super.key,
    required this.gradeFilters,
    required this.lessonFilters,
    required this.onFilterChange,
  });

  final Map<String, bool> gradeFilters;
  final Map<String, Map<String, bool>> lessonFilters;
  final Function(Map<String, bool>, Map<String, Map<String, bool>>)
  onFilterChange;

  @override
  State<GradeFilterWidget> createState() => _GradeFilterWidgetState();
}

class _GradeFilterWidgetState extends State<GradeFilterWidget> {
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => FilterDialog(
            gradeFilters: widget.gradeFilters,
            lessonFilters: widget.lessonFilters,
            onApply: (newGradeFilters, newLessonFilters) {
              widget.onFilterChange(newGradeFilters, newLessonFilters);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: [
                // "Tümü" option
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tümü'),
                    selected: widget.gradeFilters.values.every(
                      (enabled) => enabled,
                    ),
                    onSelected: (_) {
                      final allEnabled = widget.gradeFilters.values.every(
                        (enabled) => enabled,
                      );
                      for (var grade in widget.gradeFilters.keys) {
                        widget.gradeFilters[grade] = !allEnabled;
                        if (!allEnabled) {
                          // Enable all lessons when enabling all grades
                          widget.lessonFilters[grade]?.updateAll(
                            (_, __) => true,
                          );
                        }
                      }

                      widget.onFilterChange(
                        widget.gradeFilters,
                        widget.lessonFilters,
                      );
                    },
                    showCheckmark: false,
                    selectedColor: const Color(0xFF2E7D32),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color:
                          widget.gradeFilters.values.every((enabled) => enabled)
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                // Grade filters
                ...widget.gradeFilters.keys.map((grade) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$grade. Sınıf'),
                      selected: widget.gradeFilters[grade] ?? false,
                      onSelected: (_) {
                        widget.gradeFilters[grade] =
                            !(widget.gradeFilters[grade] ?? false);
                        // Update lesson filters when grade is toggled
                        if (widget.gradeFilters[grade]!) {
                          widget.lessonFilters[grade]?.updateAll(
                            (_, __) => true,
                          );
                        } else {
                          widget.lessonFilters[grade]?.updateAll(
                            (_, __) => false,
                          );
                        }

                        widget.onFilterChange(
                          widget.gradeFilters,
                          widget.lessonFilters,
                        );
                      },
                      showCheckmark: false,
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color:
                            (widget.gradeFilters[grade] ?? false)
                                ? Colors.white
                                : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
