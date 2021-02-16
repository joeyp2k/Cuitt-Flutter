import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/user.dart';
import 'package:flutter/material.dart';

final firestoreInstance = FirebaseFirestore.instance;

class UserList extends StatelessWidget {
  void user() {
    //get user data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
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
