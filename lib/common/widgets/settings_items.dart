import 'package:flutter/material.dart';
import '../color/colors.dart';

class SettingsItems extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool check;
  final VoidCallback onTap;

  SettingsItems({
    required this.icon,
    required this.label,
    required this.value,
    required this.check,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Coloors.blueLight,
      ),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value),
          check == true ? Icon(Icons.chevron_right) : SizedBox.shrink(), // Use SizedBox.shrink()
        ],
      ),
      onTap: onTap,
    );
  }
}