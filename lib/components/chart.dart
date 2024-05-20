import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> datas;
  const _BarChart(this.datas, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 1000000,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.blue.shade600,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final str = getTitlesData();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(str[value.toInt()], style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  // Function to get all titles from the list
  List<String> getTitlesData() {
    return datas
        .where((map) => map.containsKey('title'))
        .map((map) => map['title'] as String)
        .toList();
  }

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.cyan.shade600,
          Colors.blue.shade600,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  // final List<Map<String, dynamic>> datas;
  List<BarChartGroupData> get barGroups => List.generate(datas.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: datas[i]['amount'].toDouble(),
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        );
      });
}

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3({super.key, required this.data});
  final List<Map<String, dynamic>> data;

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  get datas => widget.data;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _BarChart(datas),
        ),
      ),
    );
  }
}
