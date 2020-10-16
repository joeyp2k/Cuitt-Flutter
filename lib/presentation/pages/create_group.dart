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
        backgroundColor: LightBlue,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                height: gridSpacer * 15,
                color: LightBlue,
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: spacer.x.sm + spacer.bottom.xs,
                  child: RichText(
                    text: TextSpan(
                      text: "Create Group",
                      style: TileData,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Background,
                  child: Center(
                    child: Padding(
                      padding: spacer.x.xs,
                      child: Column(
                        children: [
                          Padding(
                            padding: spacer.y.sm,
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
                          DashboardButton(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
