import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback function;

  DashboardButton(
      {Key key,
      this.text,
      this.color,
      this.icon,
      this.iconColor,
      this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: TransWhite,
        onTap: (() {
          function();
        }),
        child: Container(
          padding: spacer.all.sm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 50,
              ),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: text,
                    style: TileButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
