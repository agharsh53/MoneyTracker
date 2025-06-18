import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../database/local/category.dart';
import '../../../database/local/data_item.dart';
import '../../../database/local/database_helper.dart';
import '../screens/add_expenses_screen.dart';
import 'edit_expense_screen.dart';

class TransactionDetail extends StatefulWidget {
  final String title;
  final double amount;
  final DateTime date;
  final IconData categoryIcon;
  final Color categoryColor;
  final String note;
  final int categoryId;
  final String dataType;
  final int itemId;

  const TransactionDetail({
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryIcon,
    required this.categoryColor,
    required this.note,
    required this.categoryId,
    required this.dataType,
    required this.itemId,
    super.key,
  });

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.keyboard_arrow_left,
              size: 40,
            )),
        title: const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            // In the _TransactionDetailState class within TransactionDetail widget

            onPressed: () async {
              print("Edit button pressed for item ID: ${widget.itemId}"); // DEBUG
              try {

                final categories = await dbHelper.getCategoriesByType(widget.categoryId <= 12
                    ? CategoryType.expense
                    : widget.categoryId > 12 && widget.categoryId <= 18
                    ? CategoryType.income
                    : CategoryType.loan);

                final category = categories.firstWhere(
                      (c) => c.name == widget.title,
                  orElse: () => Category(
                    id: widget.categoryId,
                    name: widget.title,
                    icon: widget.categoryIcon,
                    color: widget.categoryColor,
                    categoryType: widget.categoryId <= 12
                        ? CategoryType.expense
                        : widget.categoryId > 12 && widget.categoryId <= 18
                        ? CategoryType.income
                        : CategoryType.loan,
                  ),
                );

                final result = await Navigator.push( // Capture the result
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditExpenseScreen(
                      dataItem: DataItem(
                        id: widget.itemId,
                        amount: widget.amount,
                        note: widget.note,
                        dateTime: widget.date,
                        category: category,
                        dataType: widget.dataType,
                      ),
                    ),
                  ),
                );

                if (result != null && result == true) {
                  // Optionally show a confirmation message here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction updated")),
                  );
                  // After successful edit, navigate back to HomePage
                  Navigator.pop(context);
                  // You might also want to trigger a refresh immediately here,
                  // but since HomePage will rebuild on becoming active, it might not be necessary.
                }
              } catch (e) {
                print("Error during navigation to edit screen: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error while trying to edit transaction")),
                );
              }
            },
      child: const Text(
              'Edit',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(children: [
                Text(
                  DateFormat('EEE, dd MMM').format(widget.date),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                widget.categoryId <= 12 || widget.categoryId == 20
                    ? Text(
                    '-${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(widget.amount)}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    : Text(
                  NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(widget.amount),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
              ]),
            ),
            const SizedBox(height: 32),
            const Text(
              'Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: widget.categoryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        widget.categoryIcon,
                        color: widget.categoryColor,
                        size: 20,
                      )),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.note),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  bool check = await dbHelper.DeleteDataItem(id: widget.itemId);
                  if (check) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Transaction Deleted")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Delete Transaction",
                    style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
