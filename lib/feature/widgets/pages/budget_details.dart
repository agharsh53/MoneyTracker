import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/color/colors.dart';
import '../../../common/widgets/month_picker.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';
import 'add_budget.dart';
class BudgetDetails extends StatefulWidget {
  const BudgetDetails({super.key});

  @override
  State<BudgetDetails> createState() => _BudgetDetailsState();
}

class _BudgetDetailsState extends State<BudgetDetails> {
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
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        color: Coloors.backgroundLight,
                        size: 40,
                      ),
                    ),
                    const Text(
                      'Budget Detail',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Coloors.backgroundLight,
                      ),
                    ),


                        TextButton(
                          onPressed: () => _showMonthPicker(context),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Coloors.backgroundLight,
                            size: 20,
                          ),
                        ),

                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
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
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                  CircularPercentIndicator(
                                    radius: 60,
                                    lineWidth: 12.0,
                                    percent: percentage,
                                    progressColor: Coloors.blueLight,
                                    backgroundColor: const Color(0xE5D9D9EA),
                                    center: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Remaining",
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          "${(percentage * 100).toInt()}%",
                                          style: const TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),

                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),


                                const SizedBox(width: 30),

                                // Budget Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildBudgetRow("Budget:", NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_budget )),
                                      const SizedBox(height: 15),
                                      buildBudgetRow("Expenses:", NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalExpense )),
                                      const Divider(height: 30),
                                      buildBudgetRow("Remain:", NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_remaining)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
                            const SizedBox(height: 50,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () {
                                       _showAddBudget(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Coloors.blueLight,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(18)),
                                  ),
                                  child: Text('Add Budget'),
                                ),
                              ),
                            ),


    ]
                ),
              ),
            ),
          ),
              ),
      ]),
    );
  }

  Widget buildBudgetRow(String title, String amount) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
          const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          amount.substring(0,amount.length-3),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
