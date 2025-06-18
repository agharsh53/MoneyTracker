import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'category.dart';
import 'data_item.dart'; // Import the data classes

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final path = join(appDir.path, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT,
        icon INTEGER,
        color INTEGER,
        categoryType INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE data_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER,
        amount REAL,
        note TEXT,
        dateTime INTEGER,
        dataType TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');



    // Insert initial categories
    await _insertInitialCategories(db);
  }

  Future<void> _insertInitialCategories(Database db) async {
    await db.insert('categories', Category(id: 1,
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.red,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 2,
        name: 'Social',
        icon: Icons.people,
        color: Colors.blue,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 3,
        name: 'Traffic',
        icon: Icons.directions_car,
        color: Colors.green,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 4,
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: Colors.purple,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 5,
        name: 'Grocery',
        icon: Icons.shopping_cart,
        color: Colors.cyan,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 6,
        name: 'Education',
        icon: Icons.book_outlined,
        color: const Color(0xffec407a),
        categoryType: CategoryType.expense).toMap()); // pink.shade400
    await db.insert('categories', Category(id: 7,
        name: 'Bills',
        icon: Icons.receipt,
        color: Colors.indigo,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 8,
        name: 'Rentals',
        icon: Icons.home,
        color: Colors.orange,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 9,
        name: 'Medical',
        icon: Icons.local_hospital,
        color: Colors.teal,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 10,
        name: 'Investment',
        icon: Icons.show_chart,
        color: Colors.grey,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 11,
        name: 'Gift',
        icon: Icons.card_giftcard,
        color: Colors.yellow,
        categoryType: CategoryType.expense).toMap());
    await db.insert('categories', Category(id: 12,
        name: 'Other',
        icon: Icons.more_horiz,
        color: Colors.brown,
        categoryType: CategoryType.expense).toMap());

    // Income
    await db.insert('categories', Category(id: 13,
        name: 'Salary',
        icon: Icons.attach_money,
        color: const Color(0xff388e3c),
        categoryType: CategoryType.income).toMap()); // green.shade700
    await db.insert('categories', Category(id: 14,
        name: 'Invest',
        icon: Icons.trending_up,
        color: const Color(0xff1976d2),
        categoryType: CategoryType.income).toMap()); // blue.shade700
    await db.insert('categories', Category(id: 15,
        name: 'Business',
        icon: Icons.business,
        color: const Color(0xff00796b),
        categoryType: CategoryType.income).toMap()); // teal.shade700
    await db.insert('categories', Category(id: 16,
        name: 'Interest',
        icon: Icons.account_balance,
        color: const Color(0xfff57c00),
        categoryType: CategoryType.income).toMap()); // orange.shade700
    await db.insert('categories', Category(id: 17,
        name: 'Extra Income',
        icon: Icons.monetization_on,
        color: const Color(0xffffa000),
        categoryType: CategoryType.income).toMap()); // amber.shade700
    await db.insert('categories', Category(id: 18,
        name: 'Other',
        icon: Icons.more_horiz,
        color: Colors.brown,
        categoryType: CategoryType.income).toMap());

    // Loan
    await db.insert('categories', Category(id: 19,
        name: 'Loan',
        icon: Icons.trending_up,
        color: const Color(
            0xff1fc12b),
        categoryType: CategoryType.loan).toMap()); // green.shade900
    await db.insert('categories', Category(id: 20,
        name: 'Borrow',
        icon: Icons.trending_down,
        color: const Color(
            0xfff73734),
        categoryType: CategoryType.loan).toMap()); // red.shade400
  }


  // Category Operations
  Future<List<Category>> getCategoriesByType(CategoryType categoryType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'categoryType = ?',
      whereArgs: [categoryType.index],
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<Category?> getCategory(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Category.fromMap(maps.first);
  }

  // DataItem Operations
  Future<bool> insertDataItem(DataItem dataItem) async {
    final db = await database;
    int rowEffected = await db.insert('data_items', dataItem.toMap(),);
    return rowEffected > 0;
  }

  Future<List<DataItem>> getDataItemsByType(String dataType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'data_items',
      where: 'dataType = ?',
      whereArgs: [dataType],
    );

    return await Future.wait(maps.map((map) async {
      final category = await getCategory(map['categoryId']);
      return DataItem.fromMap(map, category!);
    }));
  }

  Future<List<DataItem>> getAllDataItems() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('data_items',orderBy: 'dateTime DESC',);

    List<DataItem> items = [];

    for (var map in maps) {
      final categoryId = map['categoryId'];

      if (categoryId != null) {
        Category? category = await getCategoryById(categoryId as int);

        if (category != null) {
          items.add(DataItem(
            id: map['id'] as int?,
            category: category,
            amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
            note: map['note'] as String? ?? '',
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                map['dateTime'] as int? ?? 0),
            dataType: map['dataType'] as String? ?? '',
          ));
        }
      }
    }

    return items;
  }


// Add this helper method to get category by ID:
  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Category(
        id: map['id'] as int,
        name: map['name'] as String,
        icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
        color: Color(map['color'] as int),
        categoryType: CategoryType.values[map['categoryType'] as int],
      );
    }

    return null;
  }

  Future<bool> DeleteDataItem({required int id}) async {
    final db = await database;
    int rowsEffected = await db.delete(
        'data_items', where: "id = ?", whereArgs: ['$id']);
    return rowsEffected > 0;
  }

  Future<bool> updateDataItem(DataItem item) async {
    final db = await database;
    print("Attempting to update data item with ID: ${item.id} and data: ${item
        .toMap()}"); // DEBUG
    int result = await db.update(
      'data_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: ['${item.id}'],
    );
    print("Number of rows updated: $result"); // DEBUG
    return result > 0;
  }

  Future<List<Map<String, dynamic>>> fetchMonthlySummary(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      strftime('%m', datetime(dateTime / 1000, 'unixepoch')) AS month,
      SUM(CASE WHEN dataType = 'expense' THEN amount ELSE 0 END) AS expense,
      SUM(CASE WHEN dataType = 'income' THEN amount ELSE 0 END) AS income,
      SUM(CASE WHEN categoryId = 19 THEN amount ELSE 0 END) AS loan,
      SUM(CASE WHEN categoryId = 20 THEN amount ELSE 0 END) AS borrow
    FROM data_items 
    WHERE strftime('%Y', datetime(dateTime / 1000, 'unixepoch')) = ?
    GROUP BY strftime('%m', datetime(dateTime / 1000, 'unixepoch'))
    ORDER BY strftime('%m', datetime(dateTime / 1000, 'unixepoch'))
  ''', [year.toString()]);

    return result;
  }

}