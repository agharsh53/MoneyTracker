import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double percentage;
  final double amount;
  final Color color;
  final VoidCallback? onTap;

  const StatisticListTile({
    required this.icon,
    required this.title,
    required this.percentage,
    required this.amount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          title:  ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          ),),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.normal,fontStyle: FontStyle.italic)),
              Text(
                '${NumberFormat.currency(locale: 'en_IN', symbol: '₹',decimalDigits: 0).format(amount)}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

        ),
        Divider(),
      ],
    );
  }
}
