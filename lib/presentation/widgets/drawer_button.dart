import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/pages/drawer.dart';
import 'package:flutter/material.dart';

bool drawer = false;

class DrawerButton extends StatefulWidget {
  @override
  _DrawerButtonState createState() => _DrawerButtonState();
}

class _DrawerButtonState extends State<DrawerButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    drawer ? _controller.forward() : _controller.reverse();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void _handleOnPressed() {
    drawer = !drawer;
    setState(() {
      if (drawer == true) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return DrawerPage(
                transitionAnimation: animation,
              );
            },
            transitionDuration: Duration(seconds: 1),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleOnPressed(),
      child: Container(
        child: AnimatedIcon(
          color: White,
          icon: AnimatedIcons.menu_close,
          progress: _controller,
        ),
      ),
    );
  }
}
