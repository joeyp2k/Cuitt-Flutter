import 'package:cuitt/data/datasources/keys.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:flutter/material.dart';

class GroupIDBox extends StatefulWidget {
  @override
  _GroupIDBoxState createState() => _GroupIDBoxState();
}

class _GroupIDBoxState extends State<GroupIDBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DarkBlue,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: spacer.x.xs + spacer.y.md,
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
