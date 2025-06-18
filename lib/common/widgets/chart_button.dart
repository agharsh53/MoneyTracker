import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class ChartButton extends StatelessWidget {
  final IconData icon;
  final String chartType;
  final String selectedChart;
  final Function(String) onChartSelected;

  const ChartButton({super.key, 
    required this.icon,
    required this.chartType,
    required this.selectedChart,
    required this.onChartSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () => onChartSelected(chartType),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selectedChart == chartType
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20,color: selectedChart == chartType? Colors.blue:Colors.blue,),
        ),
      ),
    );
  }
}
