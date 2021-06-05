import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/settings/data/datasources/settings.dart';
import 'package:cuitt/features/settings/presentation/widgets/dashboard_button.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: Column(
          children: [
            DashboardButton(
              color: settingsTile.color,
              text: settingsTile.header,
              icon: Icons.settings,
              iconColor: White,
              function: () {
                return null;
              },
            ),
            Padding(
              padding: spacer.x.xs,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: TransWhite,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    margin: spacer.top.xs,
                    padding: spacer.left.xs,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: spacer.top.xs,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                    style: TileHeader, text: 'Limit Locking'),
                              ),
                              Padding(
                                padding: spacer.bottom.xs,
                                child: RichText(
                                  text: TextSpan(
                                      style: TileHeader,
                                      text:
                                          'Automatically cut power when you have reached max draw length to maintain progress toward your goals'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: limLockValue,
                          onChanged: (value) {
                            setState(() {
                              limLockValue = value;
                              print(limLockValue);
                            });
                          },
                          activeTrackColor: Green,
                          activeColor: Green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: spacer.x.xs,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: TransWhite,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    margin: spacer.top.xs,
                    padding: spacer.left.xs,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: spacer.top.xs,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                    style: TileHeader,
                                    text: 'Suggestion Locking'),
                              ),
                              Padding(
                                padding: spacer.bottom.xs,
                                child: RichText(
                                  text: TextSpan(
                                      style: TileHeader,
                                      text:
                                          'Automatically cut power when Cuitt suggests you end your draw'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: sugLockValue,
                          onChanged: (value) {
                            setState(() {
                              sugLockValue = value;
                              print(limLockValue);
                            });
                          },
                          activeTrackColor: Green,
                          activeColor: Green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
