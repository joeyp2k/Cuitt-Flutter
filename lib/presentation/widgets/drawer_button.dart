import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/pages/dashboard.dart';
import 'package:cuitt/presentation/pages/drawer.dart';
import 'package:flutter/material.dart';

bool drawer = false;

class EnterExitRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;

  EnterExitRoute({this.exitPage, this.enterPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation),
                child: exitPage,
              ),
              FadeTransition(
                opacity: new Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(animation),
                child: enterPage,
              ),
            ],
          ),
        );
}

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
    print('dispose');
    _controller.dispose();
    super.dispose();
  }

  @override
  void _handleOnPressed() {
    drawer = !drawer;
    setState(() {
      if (drawer == true) {
        _controller.reverse();
        Navigator.push(context,
          EnterExitRoute(exitPage: Dashboardb(), enterPage: DrawerPage()),
        );
      } else {
        _controller.reverse();
        Navigator.push(context,
          EnterExitRoute(enterPage: Dashboardb(), exitPage: DrawerPage()),
        );
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
