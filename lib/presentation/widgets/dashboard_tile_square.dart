import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class DashboardTile extends StatefulWidget {
  final String header;
  final String data;


  DashboardTile({Key key, this.header, this.data}) : super(key: key);

  @override
  _DashboardTileState createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: TransWhite,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        padding: spacer.all.sm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TileHeader,
                text: widget.header,
              ),
            ),
            Padding(
              padding: spacer.top.xxs,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TileDataLarge,
                  text: widget.data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
