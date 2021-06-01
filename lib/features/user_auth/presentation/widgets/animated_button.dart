import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback function;
  final EdgeInsets paddingStart;
  final EdgeInsets paddingEnd;
  final bool processing;

  AnimatedButton(
      {Key key,
      this.text,
      this.function,
      this.paddingStart,
      this.paddingEnd,
      this.processing})
      : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animOpac;
  Animation<double> _animTextOpac;
  Timer timeout;
  bool processing;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    final curve = CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: Curves.decelerate,
        ),
        parent: _controller);
    _animOpac = Tween<double>(begin: 0, end: 1).animate(curve);
    _animTextOpac = Tween<double>(begin: 1, end: 0).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        widget.function();
      }),
      child: AnimatedPadding(
        duration: Duration(milliseconds: 750),
        curve: Curves.easeIn,
        padding: widget.processing
            ? spacer.x.xxl * 2.8 + spacer.y.xs
            : widget.paddingStart + spacer.y.xs,
        child: AnimatedContainer(
          padding: widget.processing
              ? spacer.y.xs * 1.3
              : spacer.y.xxs + spacer.top.xs * 0.5,
          decoration: BoxDecoration(
            color: widget.processing ? DarkBlue : Green,
            borderRadius:
                BorderRadius.all(Radius.circular(widget.processing ? 75 : 30)),
          ),
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: widget.processing ? 1 : 0,
                duration: Duration(seconds: 2),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(White),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: widget.processing ? 0 : 1,
                duration: Duration(seconds: 1),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: ButtonRegular,
                      text: widget.text,
                    ),
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
