import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/presentation/pages/user.dart';
import 'package:cuitt/features/groups/presentation/widgets/overview_graph.dart';
import 'package:flutter/material.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class UserTile extends StatefulWidget {
  int index;

  UserTile({
    Key key,
    this.index,
  }) : super(key: key);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  void user() {
    //TODO: get complete user data
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: spacer.y.xxs,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        onTap: () {
          username = '${userNameList[widget.index]}';
          user();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return UserDashboard();
          }));
        },
        child: Container(
          padding: spacer.x.xs,
          decoration: BoxDecoration(
            color: TransWhite,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          height: gridSpacer * 10,
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${userNameList[widget.index]}',
                          style: primaryList,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Daily Average: ' + 'USER DAILY AVERAGE',
                          style: primaryList,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.people,
                    size: 50,
                  ),
                ],
              ),
              OverviewChart(),
              Container(
                decoration: BoxDecoration(
                  color: Green,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Today\'s Total: ' + 'USER TODAYS TOTAL',
                    style: primaryList,
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
