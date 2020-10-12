import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color iconColor;
  final IconData icon;

  DashboardButton({Key key, this.text, this.color, this.icon, this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(30)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        splashColor: Colors.transparent,
        highlightColor: DarkBlue,
        onTap: (() {
          print("Tap");
        }),
        child: Container(
          padding: spacer.all.sm,
          child: Column(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 50,
              ),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: text,
                    style: TileHeader,
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
