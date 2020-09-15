import 'package:flutter/material.dart';

class TemperatureWidget extends StatefulWidget {
  final double temperature;

  TemperatureWidget({this.temperature});

  @override
  _TemperatureWidgetState createState() => _TemperatureWidgetState();
}

class _TemperatureWidgetState extends State<TemperatureWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.temperature.toString() + "°C",
          style: TextStyle(fontSize: 50),
        ),
        Text(
          "Lillestrøm",
          style: TextStyle(fontSize: 20),
        )
      ],
    ));
  }
}
