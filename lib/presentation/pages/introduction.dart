import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/joeyp/AndroidStudioProjects/cuitt/lib/presentation/design_system/colors.dart';
import 'file:///C:/Users/joeyp/AndroidStudioProjects/cuitt/lib/presentation/design_system/icons.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animOffset, _animOffsetB;
  Animation<double> _animOpac, _animOpacB;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    super.initState();
    final curve = CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: Curves.decelerate,
        ),
        parent: _controller);
    final curveB = CurvedAnimation(
        curve: Interval(
          0.5,
          1,
          curve: Curves.decelerate,
        ),
        parent: _controller);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, -0.35), end: Offset.zero)
            .animate(curve);
    _animOffsetB =
        Tween<Offset>(begin: const Offset(0.0, -0.35), end: Offset.zero)
            .animate(curveB);
    _animOpac = Tween<double>(begin: 0, end: 1).animate(curve);
    _animOpacB = Tween<double>(begin: 0, end: 1).animate(curveB);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Green,
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: spacer.all.sm,
                    child: FadeTransition(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: RichText(
                          text: TextSpan(
                            text: "Skip",
                            style: ButtonRegular,
                          ),
                        ),
                      ),
                      opacity: _controller,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: spacer.bottom.xxl,
                    child: cuittLogo,
                  ),
                  FadeTransition(
                    child: SlideTransition(
                      position: _animOffset,
                      child: RichText(
                        text: TextSpan(
                          text: "Welcome to Cuitt",
                          style: primaryH1Bold,
                        ),
                      ),
                    ),
                    opacity: _animOpac,
                  ),
                  Padding(
                    padding: spacer.x.md,
                    child: FadeTransition(
                      child: SlideTransition(
                        position: _animOffsetB,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                                "Your vape analytics curated to take control of your consumption",
                            style: primaryPLight,
                          ),
                        ),
                      ),
                      opacity: _animOpacB,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
