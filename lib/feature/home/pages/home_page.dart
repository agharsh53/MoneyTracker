import 'package:flutter/material.dart';
import 'package:money_tracker/feature/widgets/screens/add_expenses_screen.dart';
import 'package:money_tracker/feature/widgets/screens/budget_screen.dart';
import 'package:money_tracker/feature/widgets/screens/home_screen.dart';
import 'package:money_tracker/feature/widgets/screens/setttings_screen.dart';
import 'package:money_tracker/feature/widgets/screens/statistic_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticScreen(),
    const BudgetScreen(),
    const SetttingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 30,),
      const Icon(Icons.analytics, size: 30,),
      const Icon(Icons.add, size: 30,),
      const Icon(Icons.settings, size: 30,),
    ];
    return Scaffold(

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,

        shape: const CircularNotchedRectangle(),
        notchMargin: 14,
        elevation: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.pie_chart, "Statistics", 1),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.account_balance_wallet, "Budget", 2),
            _buildNavItem(Icons.settings, "Settings", 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddExpensesScreen()));
        },
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.blueAccent, width: 12,style: BorderStyle.solid)
        ),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32, color: Colors.blueAccent, ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
        onTap: () {
      setState(() {
        _selectedIndex = index;
      });
    },
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(icon, size: 30, color: _selectedIndex == index ? Colors.blueAccent : Colors.grey),
    Text(label, style: TextStyle(color: _selectedIndex == index ? Colors.blueAccent : Colors.grey)),
    ],
    ),
    );
  }

}
