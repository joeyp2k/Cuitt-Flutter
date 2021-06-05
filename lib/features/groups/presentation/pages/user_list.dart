import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:flutter/material.dart';

import 'user.dart';

final firestoreInstance = FirebaseFirestore.instance;

class UserList extends StatelessWidget {
  void user() {
    //get user data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      bottomSheet: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {},
            child: Container(
              color: Green,
              height: gridSpacer * 7,
              child: Column(
                children: [
                  Icon(
                    Icons.add,
                    color: White,
                  ),
                  RichText(
                    text: TextSpan(style: TileHeader, text: 'Create'),
                  ),
                ],
              ),
            ),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {},
            child: Container(
              color: LightBlue,
              height: gridSpacer * 7,
              child: Column(
                children: [
                  Icon(
                    Icons.list,
                    color: White,
                  ),
                  RichText(
                    text: TextSpan(style: TileHeader, text: 'Groups'),
                  ),
                ],
              ),
            ),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {},
            child: Container(
              color: DarkBlue,
              height: gridSpacer * 7,
              child: Column(
                children: [
                  Icon(
                    Icons.link,
                    color: White,
                  ),
                  RichText(
                    text: TextSpan(style: TileHeader, text: 'Join'),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: spacer.x.xs,
            itemCount: userNameList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: spacer.y.xxs,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  onTap: () {
                    username = '${userNameList[index]}';
                    user();
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
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
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '${userNameList[index]}',
                            style: primaryList,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
