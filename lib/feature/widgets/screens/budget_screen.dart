import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/feature/widgets/pages/add_budget.dart';
import 'package:money_tracker/feature/widgets/pages/budget_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../common/color/colors.dart';
import '../../../common/widgets/month_picker.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String _selectedMonth = '';
  double _budget = 0;
  double _totalExpense = 0;
  double _remaining = 0;
  final dbHelper = DatabaseHelper();
  late Future<List<DataItem>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSelectedMonth();
    _loadTransactions();
    _calculateTotals();
  }

  Future<void> _loadTransactions() async {
    final items = dbHelper.getAllDataItems();
    setState(() {
      _transactionsFuture = items;
    });
  }

  Future<void> _calculateTotals() async {
    final items = await dbHelper.getAllDataItems();
    double expense = 0;
    for (var item in items) {
      if (_isSameMonth(item.dateTime, _selectedMonth)) {
        if (item.dataType == 'expense' || item.category.id == 20) {
          expense += item.amount;
        }
      }
    }

    setState(() {
      _totalExpense = expense;
      _remaining = _budget - _totalExpense;
    });
  }

  void _showAddBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return AddBudget(
          initialBudget: _budget.toString(),
          onBudgetSelected: (budget) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('monthly_budget_$_selectedMonth', budget);
            setState(() {
              _budget = budget;
              _remaining = _budget - _totalExpense;
            });
          },
        );
      },
    );
  }

  bool _isSameMonth(DateTime date, String selectedMonth) {
    String formatted = DateFormat('MMM yyyy').format(date);
    return formatted == selectedMonth;
  }

  Future<void> _loadSelectedMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMonth = prefs.getString('selectedMonth') ??
        DateFormat('MMM yyyy').format(DateTime.now());
    final storedBudget =
        prefs.getDouble('monthly_budget_$storedMonth') ?? 0.0;

    setState(() {
      _selectedMonth = storedMonth;
      _budget = storedBudget;
      _remaining = _budget - _totalExpense;
    });
  }

  Future<void> _saveSelectedMonth(String month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMonth', month);
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return MonthPicker(
          initialMonth: _selectedMonth,
          onMonthSelected: (month) async {
            final prefs = await SharedPreferences.getInstance();
            final storedBudget =
                prefs.getDouble('monthly_budget_$month') ?? 0.0;

            setState(() {
              _selectedMonth = month;
              _budget = storedBudget;
              _remaining = _budget - _totalExpense;
            });
            _saveSelectedMonth(month);
            _calculateTotals();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double remainingHeight = MediaQuery.of(context).size.height * 0.77;
    double percentage =
    _budget > 0 ? ((_budget - _totalExpense) / _budget).clamp(0, 1) : 0;

    return Scaffold(
      backgroundColor: Colors.white12,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Coloors.blueLight,
                  Coloors.blueDark,
                  Coloors.blueLight2
                ],
                begin: FractionalOffset(0.5, 0.6),
                end: FractionalOffset(0.0, 0.5),
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                        color: Coloors.backgroundLight,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _selectedMonth.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showMonthPicker(context),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Coloors.backgroundLight,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            width: 1,
                            height: 60,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Budget',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_remaining),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Coloors.backgroundLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextButton(
                        onPressed: () => _showAddBudget(context),
                        child: const Icon(
                          Icons.drive_file_rename_outline_outlined,
                          color: Coloors.backgroundLight,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.24,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Coloors.backgroundLight,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30), bottom: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(22.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircularPercentIndicator(
                              radius: 108.0,
                              lineWidth: 25.0,
                              percent: percentage,
                              progressColor: Coloors.blueLight,
                              backgroundColor: const Color(0xE5D9D9EA),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Remaining",
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                  Text(
                                    "${(percentage * 100).toInt()}%",
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              footer: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Expenses: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalExpense)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.0,
                                  ),
                                ),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const BudgetDetails()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Coloors.blueLight,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                ),
                                child: Text('Budget Detail'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
