import 'package:flutter/material.dart';
class Button extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(String) onButtonChanged;

  const Button({super.key, required this.label, required this.isSelected,required this.onButtonChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onButtonChanged(label);
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}