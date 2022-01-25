import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:flutter/material.dart';

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
                  text: userAvgWaitTileHours.toString() +
                      ' hrs ' +
                      userAvgWaitTileMinutes.toString() +
                      ' min ' +
                      userAvgWaitTileSecs.toString() +
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
