import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class TextEntryBox extends StatelessWidget {
  final String text;
  final TextEditingController textController;
  final bool obscureText;

  TextEntryBox({Key key, this.text, this.textController, this.obscureText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TransWhite,
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
