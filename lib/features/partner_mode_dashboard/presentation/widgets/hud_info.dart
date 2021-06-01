import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class HUD extends StatefulWidget {
  @override
  _HUDState createState() => _HUDState();
}

class _HUDState extends State<HUD> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: primaryList,
              text: "TOTAL",
            ),
          ),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: primaryList,
                  text: "20",
                ),
              ),
              RichText(
                text: TextSpan(
                  style: primaryList,
                  text: "seconds",
                ),
              ),
              RichText(
                text: TextSpan(
                  style: primaryList,
                  text: "(+25)",
                ),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              style: primaryList,
              text: "Today",
            ),
          ),
        ],
      ),
    );
  }
}
