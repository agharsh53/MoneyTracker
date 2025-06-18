import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableText extends StatelessWidget {
  final double amount;
  const TableText(this.amount, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
          NumberFormat.currency(locale: 'en_IN', symbol: '',decimalDigits: 0).format(amount),
        style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}