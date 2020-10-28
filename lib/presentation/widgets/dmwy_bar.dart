import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//separate animated padding from the rest of widget to improve animation performance

double padValue = 0;

class DMWYBar extends StatefulWidget {
  @override
  _DMWYBarState createState() => _DMWYBarState();
}

class _DMWYBarState extends State<DMWYBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: TransWhite,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 35,
                        width: 350 / 4,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'D',
                              style: ButtonRegular,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          padValue = 0;
                        });
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 35,
                        width: 350 / 4,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'W',
                              style: ButtonRegular,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          padValue = 350 / 4;
                        });
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 35,
                        width: 350 / 4,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'M',
                              style: ButtonRegular,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          padValue = 350 / 2;
                        });
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 35,
                        width: 350 / 4,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Y',
                              style: ButtonRegular,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          padValue = 350 - 350 / 4;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Selection(),
          ],
        ),
      ],
    );
  }
}

class Selection extends StatefulWidget {
  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedPadding(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(left: padValue),
          child: Container(
            decoration: BoxDecoration(
              color: TransWhite,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            height: 35,
            width: 350 / 4,
          ),
        ),
      ],
    );
  }
}
