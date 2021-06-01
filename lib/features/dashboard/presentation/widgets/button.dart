import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback function;

  Button({Key key, this.text, this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Green,
      borderRadius: BorderRadius.all(Radius.circular(30)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        splashColor: Colors.transparent,
        highlightColor: DarkBlue,
        onTap: (() {
          function();
        }),
        child: Container(
          padding: spacer.y.xs,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Center(
            child: RichText(
              text: TextSpan(
                text: text,
                style: ButtonRegular,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
