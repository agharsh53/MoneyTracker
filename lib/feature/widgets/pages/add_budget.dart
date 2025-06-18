import 'package:flutter/material.dart';
import '../../../common/color/colors.dart';

class AddBudget extends StatefulWidget {
  final Function(double) onBudgetSelected;
  final String initialBudget;

  const AddBudget({
    super.key,
    required this.initialBudget,
    required this.onBudgetSelected,
  });

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final TextEditingController budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    budgetController.text = widget.initialBudget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,

      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Net Worth', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 72,
            child: TextFormField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 25,color: Coloors.blueLight,fontWeight: FontWeight.bold),
              decoration: InputDecoration(

                hintText: 'Enter budget here',
                hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: const BorderSide(width: 2, color: Coloors.blueLight)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Coloors.blueLight, // your custom color
                    width: 2.0,
                  ),
                ),

                // ✅ Border when the TextField is focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Coloors.blueDark, // different color on focus (optional)
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1, color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      backgroundColor: Colors.grey.withOpacity(0.3)
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize:18,color: Colors.black)),
                  ),
                ),
              ),
              const SizedBox(width: 40,),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      double budget = double.tryParse(budgetController.text) ?? 0.0;
                      widget.onBudgetSelected(budget);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1.5,),
                      backgroundColor: Coloors.blueLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize:18,color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
