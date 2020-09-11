
import 'package:flutter/widgets.dart';

class DashboardTileText extends StatefulWidget {
  final String text;

  DashboardTileText({this.text});

  @override
  _DashboardTileTextState createState() => _DashboardTileTextState();
}

class _DashboardTileTextState extends State<DashboardTileText> {
  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.all(2.0), child: Text(widget.text));
  }
}

