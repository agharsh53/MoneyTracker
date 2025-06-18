import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/local/data_item.dart';
import '../../database/local/database_helper.dart';


class LineGraphWidget extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final String selectedButton;
  final DateTime selectedMonth;

  const LineGraphWidget({
    super.key,
    required this.dbHelper,
    required this.selectedButton,
    required this.selectedMonth,
  });

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
            _isSameMonth(item.dateTime, selectedMonth))
            .toList();
        List<LineChartBarData> lines;

        if (filteredItems.isEmpty) {
          return LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [const FlSpot(0, 0)],
                  isCurved: false,
                  barWidth: 3,
                  color: Colors.grey.shade400,
                  dotData: const FlDotData(show: true),
                ),
              ],
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
              lineTouchData: const LineTouchData(enabled: false),
            ),
          );
        }

        // If data is available, create chart with actual entries
        final List<FlSpot> spots = filteredItems
            .map((entry) => FlSpot(
          entry.dateTime.day.toDouble(),  // X-axis: Day of month
          entry.amount.toDouble(),        // Y-axis: Amount
        ))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x)); // Sort by day for correct order

        return LineChart(
          LineChartData(
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF26C6DA)], // Blue to Teal
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x801E88E5), // 50% opacity blue
                      Color(0x1026C6DA), // 6% opacity teal
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 30,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  getTitlesWidget: (value, _) => Text(
                    '${value ~/ 1000}k',
                    style: const TextStyle(fontSize: 10),
                  ),
                  reservedSize: 40,
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map((spot) => LineTooltipItem(
                  '${spot.y.toInt()}',
                  const TextStyle(color: Colors.white),
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
