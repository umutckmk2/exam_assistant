// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// import '../model/enums.dart';
// import '../pages/statistics_page.dart';

// class LessonChartsWidget extends StatelessWidget {
//   const LessonChartsWidget({
//     super.key,
//     required this.lessonName,
//     required this.seletedInterval,
//     required this.data,
//   });

//   final String lessonName;

//   final List<AnswerCount> data;

//   final TimeInterval seletedInterval;

//   int _calculateMaxYValue(List<AnswerCount> data) {
//     int maxValue = 0;
//     for (var item in data) {
//       final total = item.correct + item.incorrect;
//       if (total > maxValue) {
//         maxValue = total;
//       }
//     }
//     return maxValue;
//   }

//   double _calculateYAxisInterval(int maxValue) {
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     if (maxValue <= 20) return 4;
//     return (maxValue / 5).ceil().toDouble();
//   }

//   DateFormat _getDateFormat() {
//     // Use Turkish locale for date formatting
//     switch (seletedInterval) {
//       case TimeInterval.week:
//         return DateFormat('E', 'tr_TR'); // Day of week in Turkish
//       case TimeInterval.month:
//         return DateFormat('d MMM', 'tr_TR'); // Day and month in Turkish
//       case TimeInterval.allTime:
//         return DateFormat('d MMM', 'tr_TR'); // Day, month, year in Turkish
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final maxYValue = _calculateMaxYValue(data);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//           child: Text(
//             lessonName,
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//         ),
//         SizedBox(
//           height: 250,
//           child: SfCartesianChart(
//             margin: const EdgeInsets.all(10),
//             zoomPanBehavior: ZoomPanBehavior(
//               enablePanning: true,
//               zoomMode: ZoomMode.x,
//             ),
//             primaryXAxis: CategoryAxis(
//               axisLine: const AxisLine(width: 0),
//               interval: 1,
//               labelRotation: 45,
//               initialZoomPosition: 1,
//               autoScrollingDelta: 7,
//             ),
//             primaryYAxis: NumericAxis(
//               title: AxisTitle(text: 'Soru Sayısı'),
//               minimum: 0,
//               maximum:
//                   maxYValue > 0
//                       ? maxYValue + 1
//                       : 5, // Add padding and set minimum range
//               interval: _calculateYAxisInterval(maxYValue),
//               maximumLabels: 10,
//               decimalPlaces: 0,
//               rangePadding: ChartRangePadding.none,
//               axisLabelFormatter: (AxisLabelRenderDetails details) {
//                 // Keep integer values only
//                 return ChartAxisLabel(
//                   '${details.value.toInt()}',
//                   details.textStyle,
//                 );
//               },
//             ),
//             legend: Legend(isVisible: true, position: LegendPosition.bottom),
//             tooltipBehavior: TooltipBehavior(enable: true),
//             series: <CartesianSeries<AnswerCount, String>>[
//               StackedColumnSeries<AnswerCount, String>(
//                 dataSource: data,
//                 xValueMapper:
//                     (AnswerCount data, _) => _getDateFormat().format(data.date),
//                 yValueMapper: (AnswerCount data, _) => data.correct,
//                 name: 'Doğru',
//                 color: Colors.green,
//                 dataLabelSettings: const DataLabelSettings(
//                   isVisible: true,
//                   labelAlignment: ChartDataLabelAlignment.middle,
//                   showZeroValue: false,
//                 ),
//               ),
//               StackedColumnSeries<AnswerCount, String>(
//                 dataSource: data,
//                 xValueMapper:
//                     (AnswerCount data, _) => _getDateFormat().format(data.date),
//                 yValueMapper: (AnswerCount data, _) => data.incorrect,
//                 name: 'Yanlış',
//                 color: Colors.red,
//                 dataLabelSettings: const DataLabelSettings(
//                   isVisible: true,
//                   labelAlignment: ChartDataLabelAlignment.middle,
//                   showZeroValue: false,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 32),
//       ],
//     );
//   }
// }
