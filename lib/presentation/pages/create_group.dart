import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/data/datasources/keys.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/create_admin_group.dart';
import 'package:cuitt/presentation/pages/create_casual_group.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Background,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                padding: spacer.y.xs,
                alignment: Alignment.center,
                child: Padding(
                  padding: spacer.x.sm,
                  child: RichText(
                    text: TextSpan(
                      text: "Create Group",
                      style: TileHeader,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DashboardButton(
                  color: adminTile.color,
                  text: adminTile.header,
                  icon: adminTile.icon,
                  iconColor: White,
                  function: () async {
                    randID = secureRandom.nextString(
                        length: 5,
                        charset:
                            '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CreateAdminPage();
                    }));
                  },
                ),
              ),
              Expanded(
                child: DashboardButton(
                  color: casualTile.color,
                  text: casualTile.header,
                  iconColor: White,
                  icon: casualTile.icon,
                  function: () {
                    randID = secureRandom.nextString(
                        length: 5,
                        charset:
                            '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CreateCasualPage();
                    }));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
