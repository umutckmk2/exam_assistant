import 'package:flutter/material.dart';
import 'package:osym/model/enums.dart';

class IntervalsWidget extends StatelessWidget {
  const IntervalsWidget({
    super.key,
    required this.selectedInterval,
    required this.onIntervalChanged,
  });

  final TimeInterval selectedInterval;

  final void Function(TimeInterval) onIntervalChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<TimeInterval>(
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(127),
              selectedBackgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              selectedForegroundColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            segments: const [
              ButtonSegment<TimeInterval>(
                value: TimeInterval.week,
                label: Text('Son 1 Hafta'),
                icon: Icon(Icons.calendar_view_week, size: 18),
              ),
              ButtonSegment<TimeInterval>(
                value: TimeInterval.month,
                label: Text('Son 1 Ay'),
                icon: Icon(Icons.calendar_month, size: 18),
              ),
              ButtonSegment<TimeInterval>(
                value: TimeInterval.allTime,
                label: Text('Tüm Zamanlar'),
                icon: Icon(Icons.calendar_today, size: 18),
              ),
            ],
            selected: {selectedInterval},
            onSelectionChanged: (Set<TimeInterval> selection) {
              onIntervalChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}
