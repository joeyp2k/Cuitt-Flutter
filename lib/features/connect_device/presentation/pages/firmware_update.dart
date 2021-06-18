import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_nordic_dfu/flutter_nordic_dfu.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProgressListenerListener extends DfuProgressListenerAdapter {
  @override
  void onProgressChanged(String deviceAddress, int percent, double speed,
      double avgSpeed, int currentPart, int partsTotal) {
    super.onProgressChanged(
        deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal);
    print('deviceAddress: $deviceAddress, percent: $percent');
  }
}

class FirmwareUpdate extends StatefulWidget {
  @override
  _FirmwareUpdateState createState() => _FirmwareUpdateState();
}

class _FirmwareUpdateState extends State<FirmwareUpdate> {
  bool updating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        children: [
          FloatingActionButton(onPressed: () async {
            connectBLE.flutterBlue.startScan();
            connectBLE.flutterBlue.scanResults
                .listen((List<ScanResult> results) async {
              for (ScanResult result in results) {
                if (result.device.name == "Nordic_Buttonless") {
                  print("CUITT FOUND");
                  try {
                    await result.device.connect();
                  } catch (e) {
                    print(e.toString());
                  }
                  connectBLE.flutterBlue.stopScan();
                }
              }
            });
          }),
          FloatingActionButton(
              backgroundColor: Green,
              onPressed: () async {
                await connectBLE.flutterBlue.connectedDevices.then((value) {
                  print("CONNECTED DEVICES: " + value.toString());
                });
              }),
        ],
      ),
      backgroundColor: DarkBlue,
      appBar: AppBar(
        backgroundColor: DarkBlue,
        centerTitle: true,
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'Firmware Update'),
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: spacer.bottom.xxl * 1.75 + spacer.x.xxl,
                child: GestureDetector(
                  onTap: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult != ConnectivityResult.none) {
                      try {
                        print("Connected Devices");
                        var devices = connectBLE.flutterBlue;
                        var services;
                        var characteristics;
                        await devices.connectedDevices.then((value) async {
                          for (int i = 0; i < value.length; i++) {
                            if (value[i].name == "Nordic_Buttonless") {
                              print("CUITT FOUND");
                              services = await value[i].discoverServices();
                              break;
                            }
                          }
                          print("Finding Secure DFU Service");
                          for (BluetoothService s in services) {
                            characteristics = s.characteristics;
                            for (BluetoothCharacteristic c in characteristics) {
                              //print(c.read());
                              if (c.uuid.toString() ==
                                  "568a0003-2131-4f2d-bb64-66b30c7c48bf") {
                                //var char = await c.read();
                                print("CHARACTERISTIC FOUND");
                                //TODO MIGRATE BLE BLINK TO BUTTONLESS DFU
                                //enter bootloader
                                print("ENTER BOOTLOADER");
                                //c.setNotifyValue(true);
                                await c.write([0x01], withoutResponse: false);
                              }
                            }
                          }
                        });
                        //scan for dfu device
                        /*
                        connectBLE.flutterBlue.startScan();
                        connectBLE.flutterBlue.scanResults.listen((List<ScanResult> results) async {
                          for (ScanResult result in results) {
                            //print("BLE: " + result.toString());
                            if (result.device.name == "DfuTarg") {
                              print("CUITT FOUND: " + result.device.toString());
                              connectBLE.flutterBlue.stopScan();
                              await result.device.connect();
                            }
                          }
                        });
                        await devices.connectedDevices.then((value) async {
                          for(int i = 0; i < value.length; i++){
                            //if dfu device found
                            if(value[i].name == "Nordic_Buttonless"){
                              print("DFU SERVICE FOUND: INITIATING DFU");
                              await FlutterNordicDfu.startDfu(
                                'EA:AE:28:55:CC:34', 'lib/core/dfu/app_dfu_package2.zip',
                                fileInAsset: true,
                                progressListener: ProgressListenerListener(),
                              );
                            }
                          }
                        });

                         */
                      } catch (e) {
                        print(e.toString());
                      }
                      setState(() {
                        updating = true;
                      });
                    }
                  },
                  child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      decoration: BoxDecoration(
                        color: updating ? DarkBlue : Green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: spacer.all.xs,
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: updating ? 0 : 1,
                              duration: Duration(seconds: 1),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Update Device",
                                    style: TileHeader,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: updating ? 1 : 0,
                              duration: Duration(seconds: 1),
                              child: LinearProgressIndicator(
                                color: Green,
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: spacer.x.sm * 1.2,
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: White,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(30))),
                    child: Padding(
                      padding: spacer.all.sm,
                      child: RichText(
                        text: TextSpan(
                            style: Description,
                            text:
                                "There is a new update available for your Cuitt device."
                                "\n"
                                "\n"
                                "During the update procedure, do not disconnect from the internet or turn off"
                                " your Cuitt or mobile device.  This process may take two to three minutes and cannot be stopped once it has begun.  Please wait until updating is complete before continuing use of your Cuitt device."
                                "\n"
                                "\n"
                                "Version X.X.X provides important stability and security updates, and is recommended for all users"),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
