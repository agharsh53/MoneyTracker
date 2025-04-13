import 'package:flutter/material.dart';

import '../../database/local/category.dart';


class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isSelected; // Add this

  const CategoryCard({
    Key? key,
    required this.category,
    this.isSelected = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200, // Change color if selected
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null, // Add border if selected
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            category.icon,
            color: category.color,
            size: 30,
          ),
          SizedBox(height: 8),
          Text(
            category.name,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}