import 'package:flutter/material.dart';
import '../color/colors.dart';
import 'chart_button.dart'; // Import your ChartButton class

class ChartButtonRow extends StatelessWidget {
  final String selectedChart;
  final Function(String) onChartSelected;

  const ChartButtonRow({super.key, 
    required this.selectedChart,
    required this.onChartSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        children: [
          ChartButton(
            icon: Icons.pie_chart,
            chartType: 'pie',
            selectedChart: selectedChart,
            onChartSelected: onChartSelected,
          ),
          const SizedBox(width: 8),
          ChartButton(
            icon: Icons.bar_chart,
            chartType: 'bar',
            selectedChart: selectedChart,
            onChartSelected: onChartSelected,
          ),
          const SizedBox(width: 8),
          ChartButton(
            icon: Icons.show_chart,
            chartType: 'line',
            selectedChart: selectedChart,
            onChartSelected: onChartSelected,
          ),
        ],
      ),
    );
  }
}