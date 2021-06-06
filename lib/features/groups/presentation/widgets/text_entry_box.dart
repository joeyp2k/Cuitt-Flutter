import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class TextEntryBox extends StatelessWidget {
  final String text;
  final TextEditingController textController;
  final bool obscureText;
  final Color color;

  TextEntryBox(
      {Key key, this.text, this.textController, this.obscureText, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      padding: spacer.top.xs + spacer.x.xs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: RichText(
              text: TextSpan(
                text: text,
                style: primaryList,
              ),
            ),
          ),
          Container(
            child: TextFormField(
              cursorColor: White,
              decoration: InputDecoration(
                contentPadding: spacer.bottom.xxs * 0.9,
                border: InputBorder.none,
              ),
              obscureText: obscureText,
              controller: textController,
              style: primaryEntry,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
