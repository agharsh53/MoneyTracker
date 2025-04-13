import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/feature/home/pages/home_page.dart';
import '../../../common/color/colors.dart';
import '../../../common/widgets/button_row.dart';
import '../../../database/local/category.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({Key? key}) : super(key: key);

  @override
  _AddExpensesScreenState createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  String _selectedButton = 'Expense';
  TextEditingController noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Category? _selectedCategory;
  TextEditingController amountController = TextEditingController();
  final dbHelper = DatabaseHelper();
  late Future<List<Category>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = dbHelper.getCategoriesByType(_getCategoryTypeFromString(_selectedButton));
    setState(() {

    });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveDataItem() async {
    if (_selectedCategory == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category and amount are required")),
      );
      return;
    }
    final dataItem = DataItem(
      category: _selectedCategory!,
      amount: double.parse(amountController.text),
      note: noteController.text,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      dataType: _selectedCategory!.categoryType.name,
    );

    bool check = await dbHelper.insertDataItem(dataItem);
    if (check) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction added")),
      );
      Navigator.pop(context, true); // Pass true to signal a successful add
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add transaction")),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildCategoryGrid() {
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
            alignment: WrapAlignment.spaceEvenly,
            children: categories.map((category) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    border: _selectedCategory == category
                        ? Border.all(color: Coloors.blueLight)
                        : Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SizedBox(
                    height: 38,
                    width: 99,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          category.name,
                          style: const TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 22, color: Coloors.backgroundDark)),
                ),
                TextButton(
                  onPressed: _saveDataItem,
                  child: const Text('Save', style: TextStyle(fontSize: 22, color: Coloors.blueDark)),
                ),
              ],
            ),
            ButtonRow(
              selectedButton: _selectedButton,
              onButtonChanged: (value) {
                setState(() {
                  _selectedButton = value;
                  _categoryFuture = dbHelper.getCategoriesByType(_getCategoryTypeFromString(value));
                  _selectedCategory = null;
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(child: Text('Ad Placeholder')),
            ),
            const SizedBox(height: 20),
            const Text('Amount', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'INR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.keyboard_arrow_down, color: Coloors.blueLight),
                hintStyle: const TextStyle(color: Coloors.blueLight),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            _buildCategoryGrid(),
            const SizedBox(height: 20),
            const Text('Note', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                hintStyle: const TextStyle(color: Coloors.greyLight),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Time', style: TextStyle(fontSize: 18)),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Coloors.greyLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectTime(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Coloors.greyLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}