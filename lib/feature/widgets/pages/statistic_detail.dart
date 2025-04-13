import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/color/colors.dart';
import '../../../common/widgets/header_text.dart';
import '../../../common/widgets/table_text.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';
class StatisticDetail extends StatefulWidget {
  const StatisticDetail({super.key});

  @override
  State<StatisticDetail> createState() => _StatisticDetailState();
}

class _StatisticDetailState extends State<StatisticDetail> {
  int _selectedYear = DateTime.now().year;
  final dbHelper = DatabaseHelper();
  double _totalExpense = 0;
  double _totalIncome = 0;
  late Future<List<DataItem>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Load transactions initially
    _calculateTotals(); // Also calculate totals initially
  }


  Future<void> _calculateTotals() async {
    final items = await dbHelper.getAllDataItems();
    double expense = 0;
    double income = 0;
    _loadTransactions();
    for (var item in items) {
      if (_isSameYear(item.dateTime, _selectedYear)) {
        if (item.dataType == 'expense' || item.category.id==20) {
          expense += item.amount;
        } else if (item.dataType == 'income' || item.category.id==19) {
          income += item.amount;
        }
      }
    }

    setState(() {
      _totalExpense = expense;
      _totalIncome = income;
    });
    _loadTransactions();
  }
  bool _isSameYear(DateTime date, int year) {
    return date.year == year;
  }

  Future<void> _loadTransactions() async {

    final items = dbHelper.getAllDataItems();
    setState(() {
      _transactionsFuture = items;
    }); // Trigger a rebuild to show the updated data
  }
  void _showYearPicker() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10),
              lastDate: DateTime(DateTime.now().year + 10),
              selectedDate: DateTime(_selectedYear),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _selectedYear) {
      setState(() {
        _selectedYear = selected;
      });
      await _calculateTotals(); // Call this after setState
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  },
                    child: Icon(Icons.keyboard_arrow_left, size: 40,
                      color: Colors.black,),),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(onPressed: _showYearPicker,
                      child: Text( _selectedYear.toString(), style: TextStyle(
                          color: Coloors.backgroundLight,
                          fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),),
                          backgroundColor: Coloors.blueLight),),

                  ),

                ],
              ),
              SizedBox(height: 40,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Coloors.blueDark, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total balance", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalIncome - _totalExpense)}', style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Expenses: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format( _totalExpense)}', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
                  Text("Income: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalIncome)}", style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w500,)),
                ],
              ),
              const SizedBox(height: 40),

              // Table Header with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Coloors.blueDark, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    HeaderText("Month"),
                    HeaderText("Expend"),
                    HeaderText("Income"),
                    HeaderText("Loan"),
                    HeaderText("Borrow"),
                    HeaderText("Balance"),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.fetchMonthlySummary(_selectedYear),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data found."));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final row = snapshot.data![index];
                        final month = DateFormat.MMMM().format(
                          DateFormat('MM').parse(row['month']),
                        );
                        final expend = row['expense'] ?? 0;
                        final income = row['income'] ?? 0;
                        final loan = row['loan'] ?? 0;
                        final borrow = row['borrow'] ?? 0;
                        final balance = income + loan - expend - borrow;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(month, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,),
                                  ),
                                  TableText(expend.toDouble()),
                                  TableText(income.toDouble()),
                                  TableText(loan.toDouble()),
                                  TableText(borrow.toDouble()),
                                  TableText(balance.toDouble()),
                                ],
                              ),
                            ),
                            Container(height: 1, color: Coloors.backgroundDark,)
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

