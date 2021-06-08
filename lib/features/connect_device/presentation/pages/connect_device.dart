import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectPage extends StatefulWidget {
  ConnectPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  bool _processing = false;
  bool _failure = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectBloc>(
      create: (BuildContext context) => ConnectBloc(),
      child: BlocConsumer<ConnectBloc, ConnectState>(
        listener: (context, state) {
          if (state is Loading) {
            _processing = true;
          } else if (state is Success) {
            _processing = false;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return Dashboardb(
                    opacityAnimation: animation,
                  );
                },
                transitionDuration: Duration(seconds: 1),
              ),
            );
          } else if (state is Idle) {
            _processing = false;
          } else if (state is Fail) {
            _processing = false;
            _failure = true;
          }
        },
        builder: (context, state) {
          connectBlocSink = BlocProvider.of<ConnectBloc>(context);
          return Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            backgroundColor: Background,
            body: SafeArea(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        connectBlocSink.add(Connect());
                      },
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: _processing ? Green : DarkBlue,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: _processing ? 200 : 180,
                        width: _processing ? 200 : 180,
                        duration: Duration(milliseconds: 500),
                        child: RichText(
                          text: TextSpan(
                            text: "Connect Your Cuitt",
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: RichText(
                          text: TextSpan(
                            text: "I'm a partner",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}