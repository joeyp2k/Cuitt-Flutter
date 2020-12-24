import 'package:flutter/material.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/widgets/drawer_button.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/presentation/pages/create_group.dart';
import 'package:provider/provider.dart';

class DrawerPage extends StatefulWidget {
  final Animation<double> transitionAnimation;

  const DrawerPage({Key key, this.transitionAnimation}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: spacer.left.xxs * 1.25 + spacer.top.xxs + spacer.x.xs,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DrawerButton(),
                  RichText(
                    text: TextSpan(style: TileHeader, text: 'My Activity'),
                  ),
                  IconButton(
                      color: White,
                      icon: Icon(Icons.person),
                      onPressed: () => {}),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.transitionAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1, 0),
                      end: Offset(0, 0),
                    ).animate(
                      CurvedAnimation(
                        curve: Interval(0, 0.5, curve: Curves.easeIn),
                        parent: widget.transitionAnimation,
                      ),
                    ),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: DashboardButton(
                        color: createTile.color,
                        text: createTile.header,
                        icon: Icons.add,
                        iconColor: White,
                        function: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return CreateGroupPage();
                          }));
                        },
                      ),
                    ),
                    Expanded(
                      child: DashboardButton(
                        color: joinTile.color,
                        text: joinTile.header,
                        icon: Icons.link,
                        iconColor: White,
                        function: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return CreateGroupPage();
                          }));
                        },
                      ),
                    ),
                    Expanded(
                      child: DashboardButton(
                        color: groupsTile.color,
                        text: groupsTile.header,
                        icon: Icons.list,
                        iconColor: White,
                        function: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return CreateGroupPage();
                          }));
                        },
                      ),
                    ),
                    Expanded(
                      child: DashboardButton(
                        color: settingsTile.color,
                        text: settingsTile.header,
                        icon: Icons.settings,
                        iconColor: White,
                        function: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return CreateGroupPage();
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
