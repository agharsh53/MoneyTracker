import 'category.dart';

class DataItem {
  final int? id; // Unique ID for the database
  final Category category;
  final double amount;
  final String? note;
  final DateTime dateTime;
  final String dataType; // expense, income, or loan

  DataItem({
    this.id,
    required this.category,
    required this.amount,
    this.note,
    required this.dateTime,
    required this.dataType,
  });

  @override
  String toString() {
    return 'DataItem(id: $id, category: ${category.name}, amount: $amount, note: $note, dateTime: $dateTime, dataType: $dataType)';
  }

  // Convert a DataItem object into a map for database insertion
  Map<String, dynamic> toMap() {
    final map = {

      'categoryId': category.id,
      'amount': amount,
      'note': note,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'dataType': dataType,
    };
    if (id != null) {
      map['id'] = id; // ✅ Only include ID if it’s not null
    }


    return map;
  }

  // Construct from DB row
  factory DataItem.fromMap(Map<String, dynamic> map, Category category) {
    return DataItem(
      id: map['id'] != null ? map['id'] as int : null,
      category: category,
      amount: map['amount'] as double,
      note: map['note'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      dataType: map['dataType'] as String,
    );
  }
}