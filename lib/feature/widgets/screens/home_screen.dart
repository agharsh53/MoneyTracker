import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/common/color/colors.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/balance_card.dart';
import '../../../common/widgets/button_row.dart';
import '../../../common/widgets/month_picker.dart';
import '../../../common/widgets/transaction_listtile.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';

import '../pages/transaction_detail.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  var time = DateTime.now();
  String _selectedMonth = '';
  String _selectedButton = 'Expense';
  String _searchText = ''; // Added search text state
  final TextEditingController _searchController = TextEditingController();
  double _totalExpense = 0;
  double _totalIncome = 0;
  bool _showBalance = false;
  late Future<List<DataItem>> _transactionsFuture;

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
    }); // Trigger a rebuild to show the updated data
  }
  Future<void> _calculateTotals() async {
    final items = await dbHelper.getAllDataItems();
    double expense = 0;
    double income = 0;
    _loadTransactions();
    for (var item in items) {
      if (_isSameMonth(item.dateTime, _selectedMonth)) {
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
  }
  bool _isSameMonth(DateTime date, String selectedMonth) {
    String formatted = DateFormat('MMM yyyy').format(date);
    return formatted == selectedMonth;
  }


  Future<void> _loadSelectedMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMonth = prefs.getString('selectedMonth');
    setState(() {
      _selectedMonth = storedMonth ?? DateFormat('MMM yyyy').format(DateTime.now()); // Default to current month if null
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
              _saveSelectedMonth(month); // Save the selected month
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _selectedMonth.trim(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(onPressed: ()=> _showMonthPicker(context),
                        child: const Icon(Icons.keyboard_arrow_down,color: Coloors.backgroundLight,size: 30,)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showBalance = !_showBalance;
                              });
                            },
                            child: Icon(
                              _showBalance ? Icons.visibility_off : Icons.remove_red_eye_outlined,
                              color: Coloors.backgroundLight,
                              size: 28.0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),
                      Text(
                        _showBalance

                            ? NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalIncome - _totalExpense)
                            : '******',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Coloors.backgroundLight,
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    BalanceCard(
                      title: 'Total Expense',
                      amount: NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalExpense),
                      color: Colors.red,
                      icon: Icons.trending_down,
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.blueAccent,
                    ),
                    BalanceCard(
                      title: 'Total Income',
                      amount: NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(_totalIncome),
                      color: Colors.green,
                      icon: Icons.trending_up,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content (Overlapping)
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.34,
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
                              });
                            }),
                        const SizedBox(height: 16),

                        const SizedBox(height: 16),
                        // Search Text Field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search',
                            prefixIcon: const Icon(Icons.search, color: Coloors.blueLight,size: 30,),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18)
                            ),

                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildDataItemGrid(),



                      ]
                  ),
                ),
              ),
            ),
          )],
      ),

    );
  }



  String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM HH:mm').format(date);
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
          return Center(child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox( height: 200,width: 200, child: Image.asset('assets/images/expense.png')),
                Text('Add your first $_selectedButton to get started!',style: const TextStyle(fontSize: 16 ,fontWeight: FontWeight.bold),),
                const SizedBox(height: 80,)
              ],
            ),
          ));
        }

        final filteredItems = snapshot.data!
            .where((item) => item.dataType == _selectedButton.toLowerCase() &&
            ( _isSameMonth(item.dateTime, _selectedMonth)==true &&
                (item.category.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                    item.note!.toLowerCase().contains(_searchText.toLowerCase()) ||
                    item.amount.toString().contains(_searchText))))
            .toList();
        if (filteredItems.isEmpty) {
          return Center(child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox( height: 200,width: 200, child: Image.asset('assets/images/expense.png')),
                Text('Add your first $_selectedButton to get started!',style: const TextStyle(fontSize: 16 ,fontWeight: FontWeight.bold),),
                const SizedBox(height: 80,)
              ],
            ),
          ));
        }
        return Column(
          children: filteredItems.map((item) {
            return TransactionListTile(
                onTap: ()=>_navigateToTransactionDetail(item),
                item.category.icon,
                item.category.name,
                formatDate(item.dateTime),
                '₹${item.amount.toStringAsFixed(0)}',
                '${item.note}',
                '${item.category.id}',
                item.category.color,
                item.dataType,
                '${item.id}'
            );
          }).toList(),
        );
      },
    );
  }


}
