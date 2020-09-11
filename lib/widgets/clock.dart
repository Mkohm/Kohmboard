
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Clock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTime(),
            style: TextStyle(fontSize: 50),
          ),
          Text(
            getDate(),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  String getTime() {
    DateTime today = new DateTime.now();

      return DateFormat('HH:mm').format(today);
  }

  String getDate() {
    DateTime today = new DateTime.now();
    return DateFormat('EEEE, d MMM').format(today);
  }
}