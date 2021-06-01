import 'dart:async';

import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/joeyp/AndroidStudioProjects/cuitt/lib/presentation/bloc/dashboard_bloc.dart';

class AverageTimeBetweenTile extends StatefulWidget {
  final String header;
  final String textData;
  final Color color;

  AverageTimeBetweenTile({Key key, this.header, this.textData, this.color})
      : super(key: key);

  @override
  _AverageWaitPeriodTile createState() => _AverageWaitPeriodTile();
}

class _AverageWaitPeriodTile extends State<AverageTimeBetweenTile> {
  Timer refreshTimer;

  //DS3231Time + 946684800 = UnixTime
  @override
  void initState() {
    // TODO: implement initState
    refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
    super.initState();
  }

  void dispose() {
    refreshTimer.cancel();
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  text:
                      Duration(seconds: timeBetweenAverage.round())
                              .inHours
                              .toString() +
                          ' hrs ' +
                          Duration(seconds: timeBetweenAverage.round())
                              .inMinutes
                              .toString() +
                          ' min ' +
                          Duration(seconds: timeBetweenAverage.round())
                              .inSeconds
                              .toString() +
                          ' secs',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
