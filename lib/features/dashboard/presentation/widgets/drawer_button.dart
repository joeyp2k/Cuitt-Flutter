import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
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
        counterBlocSink.add(OpenDrawerEvent());
      } else {
        _controller.reverse();
        counterBlocSink.add(CloseDrawerEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleOnPressed(),
      child: Container(
        padding: spacer.all.xs - spacer.left.xxs * 0.9,
        child: AnimatedIcon(
          color: White,
          icon: AnimatedIcons.menu_close,
          progress: _controller,
        ),
      ),
    );
  }
}
