import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback function;

  AnimatedButton({Key key, this.text, this.function}) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animOpac;

  bool processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    _animOpac = Tween<double>(begin: 0, end: 1).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: processing ? spacer.y.xs : 0,
      decoration: BoxDecoration(
        color: processing ? Green : DarkBlue,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: GestureDetector(
        onTap: (() {
          processing = true;
          _controller.forward();
          widget.function();
        }),
        child: FadeTransition(
          opacity: _animOpac,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: widget.text,
                style: ButtonRegular,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
