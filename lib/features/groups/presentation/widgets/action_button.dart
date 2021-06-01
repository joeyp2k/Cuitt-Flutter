import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String text;
  final VoidCallback function;
  final EdgeInsets paddingStart;
  final EdgeInsets paddingEnd;
  final bool success;

  ActionButton(
      {Key key,
      this.text,
      this.function,
      this.paddingStart,
      this.paddingEnd,
      this.success})
      : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animOpac;
  Animation<double> _animTextOpac;
  Timer timeout;

  bool processing = false;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    super.initState();
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
      onTap: (() async {
        processing = true;
        _controller.forward();
        setState(() {});
        await widget.function();
        if (widget.success != true) {
          processing = false;
          _controller.reverse();
        }
        setState(() {});
      }),
      child: AnimatedPadding(
        duration: Duration(milliseconds: 750),
        curve: Curves.easeIn,
        padding: processing
            ? spacer.x.xxl * 2.8 + spacer.y.xs
            : widget.paddingStart + spacer.y.xs,
        child: AnimatedContainer(
          padding: processing
              ? spacer.y.xs * 1.3
              : spacer.y.xxs + spacer.top.xs * 0.5,
          decoration: BoxDecoration(
            color: processing ? DarkBlue : Green,
            borderRadius:
                BorderRadius.all(Radius.circular(processing ? 75 : 30)),
          ),
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: Stack(
            children: [
              FadeTransition(
                opacity: _animOpac,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(White),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _animTextOpac,
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
