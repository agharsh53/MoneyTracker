import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart';

import '../color/colors.dart';
class TransactionListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final String note;
  final String id;
  final Color color;
  final String dataType;
  final String itemId ;
  final VoidCallback? onTap;
  const TransactionListTile(this.icon, this.title, this.subtitle, this.trailing, this.note, this.id, this.color, this.dataType, this.itemId, {super.key, this.onTap});

  @override
  State<TransactionListTile> createState() => _TransactionListTileState();
}

class _TransactionListTileState extends State<TransactionListTile> {


  @override
  Widget build(BuildContext context) {

// Get date part (before last 5 characters)
    String datePart = widget.subtitle.substring(0, widget.subtitle.length - 6).trim();

// Get time part (last 5 characters)
    String timePart = widget.subtitle.substring(widget.subtitle.length - 5);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              datePart,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.trailing,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        ListTile(
          onTap: widget.onTap,
          leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: widget.color,size: 20.0,)),
          title: Text(widget.title,style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(widget.note),
          trailing: SizedBox(

              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              int.parse(widget.id) <= 12 || int.parse(widget.id)==20 ? Text('-${widget.trailing}', style: const TextStyle(color: Colors.red,fontSize: 16)):  Text(widget.trailing, style: const TextStyle(color: Colors.green,fontSize: 16)) ,
              Text(timePart,style: const TextStyle(color: Colors.grey),)
            ],
          )),
        ),
        Container(width: MediaQuery.of(context).size.width,height: 1,color: Coloors.greyLight,),
        const SizedBox(height: 11,)
      ],
    );
  }
}