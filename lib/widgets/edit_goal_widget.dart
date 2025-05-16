import 'package:flutter/material.dart';

import '../model/daily_goal.dart';
import '../service/goals_service.dart';

class EditGoalWidget extends StatefulWidget {
  final DailyGoal currentGoal;
  final Function(DailyGoal) onGoalUpdated;

  const EditGoalWidget({
    super.key,
    required this.currentGoal,
    required this.onGoalUpdated,
  });

  @override
  State<EditGoalWidget> createState() => _EditGoalWidgetState();
}

class _EditGoalWidgetState extends State<EditGoalWidget> {
  late TextEditingController _questionGoalController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _questionGoalController = TextEditingController(
      text: widget.currentGoal.dailyQuestionGoal.toString(),
    );
    _selectedTime = widget.currentGoal.notifyTime;
  }

  @override
  void dispose() {
    _questionGoalController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveGoal() {
    final int questionGoal = int.tryParse(_questionGoalController.text) ?? 25;
    final newGoal = DailyGoal(
      dailyQuestionGoal: questionGoal,
      notifyTime: _selectedTime,
      solvedQuestions: 0,
    );

    GoalsService.instance.setDailyGoal(newGoal);

    // Save the goal using GoalsService
    widget.onGoalUpdated(newGoal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hedef Düzenle'),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionGoalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Günlük Soru Hedefi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Bildirim Zamanı'),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveGoal,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
