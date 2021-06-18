import 'dart:async';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:cuitt/features/connect_device/domain/usecases/connect_device.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/connect_device/presentation/pages/firmware_update.dart';
import 'package:flutter/cupertino.dart';
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
              FadeRoute(
                enterPage: Dashboardb(),
                exitPage: ConnectPage(),
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
            floatingActionButton: Row(
              children: [
                FloatingActionButton(
                    onPressed: () async {
                      var cuitt;
                      connectBLE.flutterBlue.startScan();
                      connectBLE.flutterBlue.scanResults.listen((
                          List<ScanResult> results) async {
                        for (ScanResult result in results) {
                          if (result.device.name == "Nordic_Buttonless") {
                            print("CUITT FOUND");
                            cuitt = result.device;
                            connectBLE.flutterBlue.stopScan();
                            break;
                          }
                        }
                        try {
                          await cuitt.connect();
                        } catch (e) {
                          print(e.toString());
                        }
                      });
                    }
                ),
                FloatingActionButton(
                    backgroundColor: Green,
                    onPressed: () async {
                      await connectBLE.flutterBlue.connectedDevices.then((
                          value) {
                        print("CONNECTED DEVICES: " + value.toString());
                      });
                    }
                ),
              ],
            ),
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
                          shape: BoxShape.circle,
                          color: _processing ? Green : DarkBlue,
                        ),
                        height: _processing ? 260 : 220,
                        width: _processing ? 260 : 220,
                        duration: Duration(milliseconds: 750),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: DWMY,
                              text: "Connect Your Cuitt",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: LightBlue,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: TransWhite,
                        onTap: () {
                          print("tap");
                          Navigator.of(context).push(FadeRoute(
                            exitPage: ConnectPage(),
                            enterPage: FirmwareUpdate(),
                          ));
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: spacer.all.sm,
                          child: RichText(
                            text: TextSpan(
                              text: "I do not have a Cuitt",
                            ),
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
