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

  bool _isMonday() {
    return DateTime.now().weekday == DateTime.monday;
  }

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

  Future<void> _selectTime(BuildContext context, TimeOfDay? initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveGoal() {
    final int questionGoal =
        !_isMonday()
            ? widget.currentGoal.dailyQuestionGoal
            : (int.tryParse(_questionGoalController.text) ??
                widget.currentGoal.dailyQuestionGoal);

    final newGoal = DailyGoal(
      dailyQuestionGoal: questionGoal,
      notifyTime: _selectedTime,
      solvedQuestions: widget.currentGoal.solvedQuestions,
    );

    GoalsService.instance.setDailyGoal(newGoal);
    widget.onGoalUpdated(newGoal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMonday = _isMonday();

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
              enabled: isMonday,
              decoration: InputDecoration(
                labelText: 'Günlük Soru Hedefi',
                border: const OutlineInputBorder(),
                helperText:
                    isMonday
                        ? null
                        : 'Soru hedefi sadece Pazartesi günleri değiştirilebilir',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Bildirim Zamanı'),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () => _selectTime(context, widget.currentGoal.notifyTime),
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
