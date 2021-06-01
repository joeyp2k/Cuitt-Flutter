import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

DateTime pingTime;

class LastPing extends StatefulWidget {
  @override
  _LastPingState createState() => _LastPingState();
}

class _LastPingState extends State<LastPing> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: RichText(
            text: TextSpan(
              text: 'Last Ping: ' + pingTime.toString(),
              style: TileDataLarge,
            ),
          ),
        ),
      ],
    );
  }
}
