import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:flutter/material.dart';

bool firstRun;
int timeUntilLast = 0;
Duration timeUntil = Duration(seconds: 0);
Timer refreshTimer;

class DashboardTileLarge extends StatefulWidget {
  final String header;
  final String textData;
  final Color color;
  final int timeUntilNext;

  DashboardTileLarge(
      {Key key, this.header, this.textData, this.color, this.timeUntilNext})
      : super(key: key);

  @override
  _DashboardTileLargeState createState() => _DashboardTileLargeState();
}

class _DashboardTileLargeState extends State<DashboardTileLarge> {
  //DS3231Time + 946684800 = UnixTime
  @override
  void initState() {
    refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (timeUntilNext == timeUntilLast) {
        if (timeUntilNext != 0) {
          setState(() {
            timeUntil = timeUntil - Duration(seconds: 1);
          });
        }
      } else {
        timeUntil = Duration(seconds: timeUntilNext);
        timeUntilLast = timeUntilNext;
      }
    });
    super.initState();
  }

  void dispose() {
    //refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        padding: spacer.all.sm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TileHeader,
                text: widget.header,
              ),
            ),
            Padding(
              padding: spacer.top.xxs,
              child: RichText(
                text: TextSpan(
                  style: TileData,
                  text: timeUntil.toString().split('.')[0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
