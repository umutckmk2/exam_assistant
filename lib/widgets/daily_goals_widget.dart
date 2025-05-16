import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/daily_goal.dart';
import '../service/auth_service.dart';
import '../service/goals_service.dart';
import 'daily_goal_percentage_widget.dart';
import 'edit_goal_widget.dart';

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
      _isLoadingGoals = true;
      if (mounted) setState(() {});

      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        _weeklyGoals = await GoalsService.instance.getThisWeekGoalRecords(
          userId,
        );

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

  @override
  void initState() {
    super.initState();
    _getWeeklyGoals();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final primaryColorLight = primaryColor.withAlpha(200);
    final textColor = Colors.white;

    // Define color scheme for charts
    final successColor = Colors.lightGreenAccent;
    final pendingColor = Colors.amberAccent;
    final chartBaseColor = Colors.white.withAlpha(175);

    if (_isLoadingGoals) {
      return Container(
        height: 450,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withAlpha(75),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(color: textColor, strokeWidth: 3),
        ),
      );
    }

    // If no goals data available
    if (_weeklyGoals == null || _weeklyGoals!.isEmpty) {
      return Container(
        height: 450,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withAlpha(75),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, color: textColor, size: 40),
            const SizedBox(height: 16),
            Text(
              "Haftalık Hedefler",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hedeflerinizi belirlemek için hesap sayfasını ziyaret edin.",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor.withAlpha(225)),
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

    return Container(
      height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(75),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  "Bugünkü İlerleme",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.edit, color: textColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => EditGoalWidget(
                            currentGoal: todayGoal,
                            onGoalUpdated: (goal) {
                              _getWeeklyGoals();
                            },
                          ),
                    );
                  },
                  tooltip: 'Düzenle',
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: textColor),
                  onPressed: () {
                    _getWeeklyGoals();
                  },
                  tooltip: 'Verileri yenile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                DailyGoalPercentageWidget(
                  title: "Soru",
                  value:
                      "${todayGoal.solvedQuestions ?? 0}/${todayGoal.dailyQuestionGoal}",
                  percentage: questionPercentage,
                  color:
                      questionPercentage >= 100 ? successColor : pendingColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haftalık Soru Çözüm Hedefi',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SfCartesianChart(
                      margin: const EdgeInsets.all(8),
                      plotAreaBorderWidth: 0,
                      plotAreaBackgroundColor: Colors.transparent,
                      primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        labelStyle: TextStyle(color: textColor, fontSize: 11),
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        axisLine: const AxisLine(width: 0),
                        majorGridLines: MajorGridLines(
                          width: 0.5,
                          color: chartBaseColor,
                          dashArray: const <double>[5, 5],
                        ),
                        majorTickLines: const MajorTickLines(size: 0),
                        maximum: 100,
                        minimum: 0,
                        interval: 50,
                        labelStyle: TextStyle(
                          color: chartBaseColor,
                          fontSize: 10,
                        ),
                        labelFormat: '{value}%',
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.y%',
                        header: '',
                        canShowMarker: false,
                        duration: 3000,
                        textStyle: TextStyle(color: textColor),
                        builder: (
                          dynamic data,
                          dynamic point,
                          dynamic series,
                          int pointIndex,
                          int seriesIndex,
                        ) {
                          final ChartData chartData =
                              _getQuestionChartData()[pointIndex];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(175),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color:
                                          chartData.completed >=
                                                  chartData.target
                                              ? successColor
                                              : pendingColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tamamlanan: ${chartData.completed}/${chartData.target}',
                                      style: TextStyle(
                                        color:
                                            chartData.completed >=
                                                    chartData.target
                                                ? successColor
                                                : pendingColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      chartData.percentage >= 100
                                          ? Icons.emoji_events
                                          : Icons.trending_up,
                                      color:
                                          chartData.percentage >= 100
                                              ? successColor
                                              : pendingColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Başarı: ${chartData.percentage.toInt()}%',
                                      style: TextStyle(
                                        color:
                                            chartData.percentage >= 100
                                                ? successColor
                                                : pendingColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      series: <CartesianSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                          dataSource: _getQuestionChartData(),
                          xValueMapper: (ChartData data, _) => data.day,
                          yValueMapper: (ChartData data, _) => data.percentage,
                          name: 'Sorular',
                          width: 0.7,
                          spacing: 0.2,
                          animationDuration: 100,
                          color: pendingColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          dataLabelSettings: DataLabelSettings(
                            isVisible: false,
                            textStyle: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            labelAlignment: ChartDataLabelAlignment.top,
                            builder: (
                              dynamic data,
                              dynamic point,
                              dynamic series,
                              int pointIndex,
                              int seriesIndex,
                            ) {
                              // Show percentage in data label
                              return Text(
                                '${data.percentage.toInt()}%',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                          pointColorMapper:
                              (ChartData data, _) =>
                                  data.percentage >= 100
                                      ? successColor
                                      : pendingColor,
                        ),
                      ],
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
