import 'package:flutter/material.dart';

import '../color/colors.dart';
import 'button.dart';

class ButtonRow extends StatelessWidget {
  final String selectedButton;
  final Function(String) onButtonChanged;

  const ButtonRow({super.key, required this.selectedButton, required this.onButtonChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the available width for the buttons
        double availableWidth = constraints.maxWidth;

        // Calculate a suitable width for each button, ensuring they fit
        double buttonWidth = availableWidth / 3; // Adjust the divisor as needed

        return Container(
          decoration: BoxDecoration(
            color: Coloors.blueLight2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: buttonWidth,
                child: Button(
                  label: 'Expense',
                  isSelected: selectedButton == 'Expense',
                  onButtonChanged: onButtonChanged,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: Button(
                  label: 'Income',
                  isSelected: selectedButton == 'Income',
                  onButtonChanged: onButtonChanged,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: Button(
                  label: 'Loan',
                  isSelected: selectedButton == 'Loan',
                  onButtonChanged: onButtonChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}