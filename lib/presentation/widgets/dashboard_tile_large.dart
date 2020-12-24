import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class DashboardTileLarge extends StatefulWidget {
  final String header;
  final String textData;
  final Color color;

  DashboardTileLarge({Key key, this.header, this.textData, this.color})
      : super(key: key);

  @override
  _DashboardTileLargeState createState() => _DashboardTileLargeState();
}

class _DashboardTileLargeState extends State<DashboardTileLarge> {
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
                  text: widget.textData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
