import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/daily_goal.dart';
import '../service/auth_service.dart';
import '../service/goals_service.dart';
import 'daily_goal_percentage_widget.dart';

class ChartData {
  final String day;
  final double percentage;
  final int completed;
  final int target;

  ChartData(this.day, this.percentage, this.completed, this.target);
}

class DailyGoalsWidget extends StatefulWidget {
  const DailyGoalsWidget({super.key});

  @override
  State<DailyGoalsWidget> createState() => _DailyGoalsWidgetState();
}

class _DailyGoalsWidgetState extends State<DailyGoalsWidget> {
  Map<String, DailyGoal>? _weeklyGoals;
  bool _isLoadingGoals = true;

  Future<void> _getWeeklyGoals() async {
    try {
      setState(() {
        _isLoadingGoals = true;
      });

      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        await GoalsService.instance.saveMissingRecords();
        final weeklyGoals = await GoalsService.instance.getThisWeekGoalRecords(
          userId,
        );
        _weeklyGoals = weeklyGoals;
        _isLoadingGoals = false;

        if (mounted) setState(() {});
      } else {
        _isLoadingGoals = false;
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Error getting weekly goals: $e");
      _isLoadingGoals = false;
      if (mounted) setState(() {});
    }
  }

  String _formatDay(String timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    return DateFormat('EEE', 'tr_TR').format(date);
  }

  List<ChartData> _getQuestionChartData() {
    if (_weeklyGoals == null) return [];

    return _weeklyGoals!.entries.map((entry) {
      final timestamp = entry.key;
      final goal = entry.value;
      final completed = goal.solvedQuestions ?? 0;
      final target = goal.dailyQuestionGoal;
      final percentage =
          target > 0
              ? (completed / target * 100).clamp(0, 100).toDouble()
              : 0.0;

      return ChartData(_formatDay(timestamp), percentage, completed, target);
    }).toList();
  }

  List<ChartData> _getTimeChartData() {
    if (_weeklyGoals == null) return [];

    return _weeklyGoals!.entries.map((entry) {
      final timestamp = entry.key;
      final goal = entry.value;
      final completed = goal.passTime ?? 0;
      final target = goal.dailyTimeGoal;
      final percentage =
          target > 0
              ? (completed / target * 100).clamp(0, 100).toDouble()
              : 0.0;

      return ChartData(_formatDay(timestamp), percentage, completed, target);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _getWeeklyGoals();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGoals) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      );
    }

    // If no goals data available
    if (_weeklyGoals == null || _weeklyGoals!.isEmpty) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              "Haftalık Hedefler",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hedeflerinizi belirlemek için hesap sayfasını ziyaret edin.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      );
    }

    // Get the data for today
    final today = GoalsService.todayMidNightAsSeconds.toString();
    final todayGoal = _weeklyGoals![today]!;
    final questionPercentage =
        todayGoal.dailyQuestionGoal > 0
            ? ((todayGoal.solvedQuestions ?? 0) /
                    todayGoal.dailyQuestionGoal *
                    100)
                .clamp(0, 100)
                .toDouble()
            : 0.0;
    final timePercentage =
        todayGoal.dailyTimeGoal > 0
            ? ((todayGoal.passTime ?? 0) / todayGoal.dailyTimeGoal * 100)
                .clamp(0, 100)
                .toDouble()
            : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Günlük Hedefler",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                DailyGoalPercentageWidget(
                  title: "Soru",
                  value:
                      "${todayGoal.solvedQuestions ?? 0}/${todayGoal.dailyQuestionGoal}",
                  percentage: questionPercentage,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                DailyGoalPercentageWidget(
                  title: "Dakika",
                  value:
                      "${todayGoal.passTime ?? 0}/${todayGoal.dailyTimeGoal}",
                  percentage: timePercentage,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    tabs: const [Tab(text: "Sorular"), Tab(text: "Zaman")],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBarView(
                        children: [
                          SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(width: 0),
                              majorGridLines: const MajorGridLines(
                                width: 0.5,
                                color: Colors.white30,
                                dashArray: <double>[5, 5],
                              ),
                              maximum: 100,
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              labelFormat: '{value}%',
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                dataSource: _getQuestionChartData(),
                                xValueMapper: (ChartData data, _) => data.day,
                                yValueMapper:
                                    (ChartData data, _) => data.percentage,
                                name: 'Sorular',
                                color: Colors.amber,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  labelAlignment: ChartDataLabelAlignment.top,
                                ),
                                pointColorMapper:
                                    (ChartData data, _) =>
                                        data.percentage >= 100
                                            ? Colors.greenAccent
                                            : Colors.amber,
                              ),
                            ],
                          ),
                          SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(width: 0),
                              majorGridLines: const MajorGridLines(
                                width: 0.5,
                                color: Colors.white30,
                                dashArray: <double>[5, 5],
                              ),
                              maximum: 100,
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              labelFormat: '{value}%',
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                dataSource: _getTimeChartData(),
                                xValueMapper: (ChartData data, _) => data.day,
                                yValueMapper:
                                    (ChartData data, _) => data.percentage,
                                name: 'Dakika',
                                color: Colors.greenAccent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  labelAlignment: ChartDataLabelAlignment.top,
                                ),
                                pointColorMapper:
                                    (ChartData data, _) =>
                                        data.percentage >= 100
                                            ? Colors.amber
                                            : Colors.greenAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
