import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/common/color/colors.dart';

import 'package:money_tracker/common/widgets/line_graph_widget.dart';
import 'package:money_tracker/feature/widgets/pages/statistic_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/bar_chart_widget.dart';
import '../../../common/widgets/button_row.dart';

import '../../../common/widgets/chart_button_row.dart';
import '../../../common/widgets/month_picker.dart';
import '../../../common/widgets/pie_chart_widget.dart';
import '../../../common/widgets/statistic_list_tile.dart';

import 'dart:ui';
import '../../../database/local/aggregated_category_data.dart';
import '../../../database/local/category.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';

import '../pages/transaction_detail.dart';
class StatisticScreen extends StatefulWidget {

  const StatisticScreen({super.key,  });

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final dbHelper = DatabaseHelper();
  var time = DateTime.now();
  String _selectedMonth = '';
  String _selectedButton = 'Expense';
  double _totalExpense = 0;
  double _totalIncome = 0;
  double _totalLoan = 0;
  late Future<List<DataItem>> _transactionsFuture;
  late Future<List<Category>> _categoryFuture;
  String _selectedChart = 'pie';
  @override
  void initState() {
    super.initState();
    _loadSelectedMonth();
    _calculateTotals();
    _loadTransactions();

    setState(() {

    });
    // Load the selected month from SharedPreferences
  }

  Future<void> _loadTransactions() async {

    final items = dbHelper.getAllDataItems();
    setState(() {
      _transactionsFuture = items;
      _categoryFuture = dbHelper.getCategoriesByType(_getCategoryTypeFromString(_selectedButton));
    }); // Trigger a rebuild to show the updated data
  }
  CategoryType _getCategoryTypeFromString(String buttonText) {
    CategoryType type;
    switch (buttonText.toLowerCase()) {
      case 'expense':
        type = CategoryType.expense;
        break;
      case 'income':
        type = CategoryType.income;
        break;
      case 'loan':
        type = CategoryType.loan;
        break;
      default:
        type = CategoryType.expense;
        break;
    }
    return type;
  }
  Future<void> _calculateTotals() async {
    final items = await dbHelper.getAllDataItems();
    double expense = 0;
    double income = 0;
    double loan = 0;
    _loadTransactions();
    for (var item in items) {
      if (_isSameMonth(item.dateTime, _selectedMonth)) {
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
  bool _isSameMonth(DateTime date, String selectedMonth) {
    String formatted = DateFormat('MMM yyyy').format(date);
    return formatted == selectedMonth;
  }


  Future<void> _loadSelectedMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMonth = prefs.getString('selectedMonth');
    setState(() {
      if (storedMonth != null && storedMonth.isNotEmpty) {
        _selectedMonth = storedMonth;
      } else {
        _selectedMonth = DateFormat('MMM yyyy').format(DateTime.now());
      }
// Default to current month if null
    });
  }

  Future<void> _saveSelectedMonth(String month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMonth', month);
    _calculateTotals();

  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return MonthPicker(
          initialMonth: _selectedMonth,
          onMonthSelected: (month) {
            setState(() {
              _selectedMonth = month;
              _saveSelectedMonth(month);
              // Save the selected month
            });
          },
        );
      },
    );
  }
  void _navigateToTransactionDetail(DataItem transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetail(
          title: transaction.category.name,
          amount: transaction.amount,
          date: transaction.dateTime,
          categoryIcon: transaction.category.icon,
          categoryColor: transaction.category.color,
          note: '${transaction.note}',
          categoryId: transaction.category.id,
          dataType: transaction.dataType,
          itemId: transaction.id!,
        ),
      ),
    );

    // If EditExpenseScreen was popped with a true result, reload transactions
    if (result != null && result == true) {
      _loadTransactions();
      _calculateTotals(); // Recalculate totals after update
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white12,

      body: Stack( // Use Stack to overlay widgets
        children: <Widget>[
          // Top Purple Section (Constant)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Coloors.blueLight, Coloors.blueDark,Coloors.blueLight2],
                begin: FractionalOffset(0.5, 0.6),
                end: FractionalOffset(0.0, 0.5),
                stops: [0.0,0.5, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: Coloors.backgroundLight,
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Row(
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                'Available Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalIncome - _totalExpense),
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
                            onPressed:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const StatisticDetail())),
                            child: const Icon(Icons.keyboard_arrow_right,color: Coloors.backgroundLight,size: 40,)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

              ],
            ),
          ),

          // Scrollable Content (Overlapping)
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.23,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(

              child: Container(
                decoration: const BoxDecoration(
                  color: Coloors.backgroundLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                          child: Column(
                              children: <Widget>[
                                ButtonRow(selectedButton: _selectedButton,
                                    onButtonChanged: (value) {
                                      setState(() {
                                        _selectedButton = value;
                                        _loadTransactions();
                                      });
                                    }),

                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedMonth.trim(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextButton(onPressed: ()=> _showMonthPicker(context),
                                              child: const Icon(Icons.keyboard_arrow_down,size: 30,)),
                                        ],
                                      ),

                                      ChartButtonRow(
                                        selectedChart: _selectedChart,
                                        onChartSelected: (type) => setState(() => _selectedChart = type),
                                      ),
                                   ]),),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Coloors.blueLight2.withOpacity(0.1), // Move color into BoxDecoration
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight:Radius.circular(10) ),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 350), // Adjust the height as needed
                                        child: _buildChart(), //Removed expanded
                                      ),
                                    ),

                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Coloors.blueLight2.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight:Radius.circular(10) ),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 320),
                                        child: Padding( // Add Padding
                                          padding: const EdgeInsets.all(8.0), // Optional: Add padding around chart
                                          child:  _buildCategoryGridLegend(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8,),
                                    _buildDataItemGrid(),
                                  const SizedBox(height: 50,)],
            ),
                                ]),),





                  ),

    ),),

    ]),
    );
  }
  Widget _buildChart() {
    final selectedMonth= _selectedMonth.isNotEmpty
        ? DateFormat("MMM yyyy").parse(_selectedMonth)
        : DateTime.now();

    switch (_selectedChart) {
      case 'pie':
        return PieChartWidget(
          dbHelper: dbHelper,
          selectedButton: _selectedButton,
          selectedMonth: selectedMonth,
        );
      case 'bar':
        return BarChartWidget(
    dbHelper: dbHelper,
    selectedButton: _selectedButton,
    selectedMonth: selectedMonth,
    );
      case 'line':
        return LineGraphWidget(dbHelper: dbHelper, selectedButton: _selectedButton, selectedMonth: selectedMonth);
      default:
        return Container();
    }
  }


  Widget _buildCategoryGridLegend() {
    return FutureBuilder<List<Category>>(
      future: _categoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final categories = snapshot.data!;

          return Wrap(
            spacing: 25,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: categories.map((category) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 4-16, // 4 per row
                child: Row(
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }



  String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy HH:mm').format(date);
  }


  List<AggregatedCategoryData> _aggregateData(List<DataItem> dataItems) {
    final Map<int, double> aggregatedAmounts = {};
    final Map<int, Category> categories = {}; // To store the Category object

    for (var item in dataItems) {
      final categoryId = item.category!.id;
      final amount = item.amount;

      aggregatedAmounts.update(categoryId, (value) => value + amount,
          ifAbsent: () => amount);
      categories.putIfAbsent(categoryId, () => item.category!);
        }

    return aggregatedAmounts.entries.map((entry) {
      final categoryId = entry.key;
      final totalAmount = entry.value;
      final category = categories[categoryId]!;
      return AggregatedCategoryData(category: category, totalAmount: totalAmount);
    }).toList();
  }


  Widget _buildDataItemGrid() {
    return FutureBuilder<List<DataItem>>(
      future: dbHelper.getAllDataItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No transactions found.'));
        }

        // Filter items based on selected button and month
        final filteredItems = snapshot.data!
            .where((item) =>
        item.dataType == _selectedButton.toLowerCase() &&
            _isSameMonth(item.dateTime, _selectedMonth))
            .toList();

        // Aggregate the filtered items by category
        final aggregatedData = _aggregateData(filteredItems);

        if (aggregatedData.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Text(
                'Add your first $_selectedButton to get started!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        // Calculate the total for percentage calculation
        // This should match how _totalExpense, _totalIncome, _totalLoan are calculated.
        // For simplicity, we can sum the aggregatedData amounts here if totals are not always up-to-date.
        // If _totalExpense, _totalIncome, _totalLoan are guaranteed to be correct for the _selectedMonth, use them.
        final double totalForPercentage = aggregatedData.fold(0.0, (sum, item) => sum + item.totalAmount);

        // Fallback if totalForPercentage is zero to avoid division by zero
        final displayPercentage = totalForPercentage == 0 ? 1.0 : totalForPercentage;


        return Column(
          children: aggregatedData.map((item) {
            return StatisticListTile(
              icon: item.category.icon, // Access icon from the aggregated category
              title: item.category.name, // Access name from the aggregated category
              percentage: item.totalAmount / displayPercentage, // Use totalAmount
              amount: item.totalAmount, // Use totalAmount
              color: item.category.color, // Access color from the aggregated category
               // Removed, as this now represents aggregated data
            );
          }).toList(),
        );
      },
    );
  }

}



