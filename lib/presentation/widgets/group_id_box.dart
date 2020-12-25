import 'package:cuitt/data/datasources/keys.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class GroupIDBox extends StatefulWidget {
  Color color;

  GroupIDBox({Key key, this.color}) : super(key: key);

  @override
  _GroupIDBoxState createState() => _GroupIDBoxState();
}

class _GroupIDBoxState extends State<GroupIDBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: spacer.y.xs,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: 'Group ID: ' + randID,
            style: TileData,
          ),
        ),
      ),
    );
  }
}
