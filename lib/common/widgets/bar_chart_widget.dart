import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/local/data_item.dart';
import '../../database/local/database_helper.dart';

class BarChartWidget extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final String selectedButton;
  final DateTime selectedMonth;

  const BarChartWidget({
    Key? key,
    required this.dbHelper,
    required this.selectedButton,
    required this.selectedMonth,
  }) : super(key: key);

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataItem>>(
      future: dbHelper.getAllDataItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final filteredItems = snapshot.data!
            .where((item) =>
        item.dataType == selectedButton.toLowerCase() &&
            item.category != null &&
            _isSameMonth(item.dateTime, selectedMonth))
            .toList();

        if (filteredItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: Colors.grey[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 6,
                            child: Text(
                              'No Data',
                              style: const TextStyle(fontSize: 12, color: Colors.black45),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                ),
              ),
            ),
          );
        }


        // Group by category and sum
        final categoryTotals = <String, double>{};
        final categoryColors = <String, Color>{};

        for (var item in filteredItems) {
          final name = item.category.name;
          categoryTotals[name] = (categoryTotals[name] ?? 0) + item.amount;
          categoryColors[name] = item.category.color;
        }

        final barGroups = categoryTotals.entries.map((entry) {
          int index = categoryTotals.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: categoryColors[entry.key],
                width: 20,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList();
        final maxYValue = categoryTotals.values.reduce((a, b) => a > b ? a : b);
        final roundedMaxY = (maxYValue / 500).ceil() * 500;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: roundedMaxY.toDouble(),
                barGroups: barGroups,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        final category = categoryTotals.keys.toList()[index];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 6,
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
