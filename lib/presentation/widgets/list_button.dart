import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class ListButton extends StatelessWidget {
  final String text;
  final Color color;

  ListButton({Key key, this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        splashColor: Colors.transparent,
        highlightColor: DarkBlue,
        onTap: (() {
          print("Tap");
        }),
        child: Row(
          children: [
            Container(
              padding: spacer.y.sm + spacer.left.sm,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: text,
                    style: primaryList,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
