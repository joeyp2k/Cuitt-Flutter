import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;

  FadeRoute({this.exitPage, this.enterPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionDuration: Duration(milliseconds: 400),
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
