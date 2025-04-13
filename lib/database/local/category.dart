import 'package:flutter/material.dart';

enum CategoryType { expense, income, loan }

class Category {
  final int id; // Unique ID for the database.
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType categoryType;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.categoryType,
  });

  @override
  String toString() {
    return 'Category(name: $name, type: $categoryType)';
  }

  // Convert a Category object into a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint, // Store icon as int code point
      'color': color.value,   // Store color as int value
      'categoryType': categoryType.index, // Store enum as index
    };
  }

  // Create a Category object from a map retrieved from the database.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'), // Retrieve icon using IconData
      color: Color(map['color']),
      categoryType: CategoryType.values[map['categoryType']],
    );
  }
}
