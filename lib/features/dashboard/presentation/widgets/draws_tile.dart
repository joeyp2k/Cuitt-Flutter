import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawsTile extends StatefulWidget {
  final String header;
  final String header2;
  final String textData;
  final String textData2;
  final Color color;

  DrawsTile(
      {Key key,
      this.header,
      this.header2,
      this.textData,
      this.textData2,
      this.color})
      : super(key: key);

  @override
  _DrawsTileState createState() => _DrawsTileState();
}

class _DrawsTileState extends State<DrawsTile> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        padding: spacer.all.sm,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TileHeader,
                    text: widget.header2,
                  ),
                ),
                Padding(
                  padding: spacer.top.xxs,
                  child: RichText(
                    text: TextSpan(
                      style: TileData,
                      text: widget.textData2,
                    ),
                  ),
                ),
              ],
            ),
            Column(
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
          ],
        ),
      ),
    );
  }
}
