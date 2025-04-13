import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import '../../database/local/data_item.dart';
import '../../database/local/database_helper.dart';


class PieChartWidget extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final String selectedButton;
  final DateTime selectedMonth;

  const PieChartWidget({
    Key? key,
    required this.dbHelper,
    required this.selectedButton,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  double _totalExpense = 0;
  double _totalIncome = 0;
  double _totalLoan = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();

    setState(() {

    });
    // Load the selected month from SharedPreferences
  }



  Future<void> _calculateTotals() async {
    final items = await widget.dbHelper.getAllDataItems();
    double expense = 0;
    double income = 0;
    double loan = 0;

    for (var item in items) {
      if (_isSameMonth(item.dateTime, widget.selectedMonth)) {
        if (item.dataType == 'expense' || item.category.id==20) {
          expense += item.amount;
        } else if (item.dataType == 'income' || item.category.id==19) {
          income += item.amount;
        }
        if(item.dataType == 'loan'){
          loan += item.amount;
        }
      }
    }

    setState(() {
      _totalExpense = expense;
      _totalIncome = income;
      _totalLoan = loan;
    });
  }
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataItem>>(
      future: widget.dbHelper.getAllDataItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final filteredItems = snapshot.data!
            .where((item) =>
        item.dataType == widget.selectedButton.toLowerCase() &&
            item.category != null &&
            _isSameMonth(item.dateTime, widget.selectedMonth))
            .toList();
        final percentage = widget.selectedButton=='Expense'?_totalExpense :widget.selectedButton == 'Income'? _totalIncome: _totalLoan;
        if (filteredItems.isEmpty) {
          return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 1,
                  title: 'No Data',
                  color: Colors.grey[300]!,
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
              ],
              centerSpaceRadius: 75,
              sectionsSpace: 0,
            ),
          );
        }


        List<PieChartSectionData> sections = filteredItems.map((entry) {
          return PieChartSectionData(
            value: entry.amount,
            title: '${entry.category.name}\n${((entry.amount/percentage)*100).toStringAsFixed(0)}%',
            radius: 70,
            color: entry.category.color.withOpacity(0.8),
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        }).toList();

        return PieChart(PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 75,
          sections: sections,
        ));
      },
    );
  }
}
