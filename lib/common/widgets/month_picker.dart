import 'package:flutter/material.dart';
import '../color/colors.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatefulWidget {
  final Function(String) onMonthSelected;
  final String initialMonth; // Add initialMonth parameter

  MonthPicker({required this.onMonthSelected, required this.initialMonth});

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  int _selectedYear = DateTime.now().year;
  String _selectedMonth = ''; // Initialize without a default selection

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  bool _isThisMonthHovered = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth; // Use initialMonth from HomeScreen
    try {
      _selectedYear = DateFormat('MMM yyyy').parse(_selectedMonth).year; // Correct parsing
    } catch (e) {
      print('Error parsing year: $e');
      _selectedYear = DateTime.now().year; // Default to current year on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Month', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
              MouseRegion(
                onEnter: (_) => setState(() => _isThisMonthHovered = true),
                onExit: (_) => setState(() => _isThisMonthHovered = false),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear = DateTime.now().year;
                      _selectedMonth = DateFormat('MMM yyyy').format(DateTime.now()); // Reset to current month
                    });
                  },
                  style: TextButton.styleFrom(
                    disabledBackgroundColor: Colors.tealAccent,
                    side: _isThisMonthHovered
                        ? BorderSide(color: Colors.blue)
                        : null,
                  ),
                  child: Text('This month'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedYear -=1;
                  });
                },
              ),
              Text(_selectedYear.toString(), style: TextStyle(fontSize: 18.0)),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedYear+= 1;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.0),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.0,
            ),
            itemCount: _months.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = '${_months[index]} $_selectedYear'; // Update month with selected year
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _selectedMonth.startsWith(_months[index])
                        ? Colors.white
                        : Colors.black,
                    backgroundColor: _selectedMonth.startsWith(_months[index])
                        ? Coloors.blueLight
                        : Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  child: Text(_months[index]),
                ),
              );
            },
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onMonthSelected('$_selectedMonth'); // Send the selected month
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Coloors.blueLight
                ),
                child: Text('Save', style: TextStyle(color: Coloors.backgroundLight)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}