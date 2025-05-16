import 'package:flutter/material.dart';

import '../../utils/lesson_utils.dart';

class FilterDialog extends StatefulWidget {
  final Map<String, bool> gradeFilters;
  final Map<String, Map<String, bool>> lessonFilters;
  final Function(Map<String, bool>, Map<String, Map<String, bool>>) onApply;

  const FilterDialog({
    super.key,
    required this.gradeFilters,
    required this.lessonFilters,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, bool> _gradeFilters;
  late Map<String, Map<String, bool>> _lessonFilters;

  @override
  void initState() {
    super.initState();
    _gradeFilters = Map.from(widget.gradeFilters);
    _lessonFilters = Map.from(widget.lessonFilters);
  }

  void _toggleGrade(String grade) {
    setState(() {
      _gradeFilters[grade] = !(_gradeFilters[grade] ?? true);
      // If grade is disabled, disable all its lessons
      if (!_gradeFilters[grade]!) {
        _lessonFilters[grade]?.updateAll((_, __) => false);
      } else {
        // If grade is enabled, enable all its lessons
        _lessonFilters[grade]?.updateAll((_, __) => true);
      }
    });
  }

  void _toggleLesson(String grade, String lesson) {
    setState(() {
      _lessonFilters[grade]?[lesson] =
          !(_lessonFilters[grade]?[lesson] ?? true);
      // Update grade status based on lessons
      _gradeFilters[grade] =
          _lessonFilters[grade]?.values.any((enabled) => enabled) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtreleme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _gradeFilters.keys.map((grade) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                '$grade. Sınıf',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              value: _gradeFilters[grade],
                              onChanged: (_) => _toggleGrade(grade),
                            ),
                            if (_gradeFilters[grade] ?? false)
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  children:
                                      _lessonFilters[grade]?.entries.map((
                                        lesson,
                                      ) {
                                        return CheckboxListTile(
                                          title: Text(
                                            LessonUtils.getLessonName(
                                              lesson.key,
                                            ),
                                          ),
                                          value: lesson.value,
                                          onChanged:
                                              (_) => _toggleLesson(
                                                grade,
                                                lesson.key,
                                              ),
                                          dense: true,
                                        );
                                      }).toList() ??
                                      [],
                                ),
                              ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(_gradeFilters, _lessonFilters);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
