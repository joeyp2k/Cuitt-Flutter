import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/domain/usecases/write_group_data.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/widgets/action_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/group_id_box.dart';
import 'package:cuitt/features/groups/presentation/widgets/text_entry_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class CreateCasualPage extends StatefulWidget {
  @override
  _CreateCasualPageState createState() => _CreateCasualPageState();
}

class _CreateCasualPageState extends State<CreateCasualPage> {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      listener: (context, state) {
        if (state is Success) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return GroupsList();
          }));
        } else if (state is Fail) {
          _success = false;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Background,
          appBar: AppBar(
            backgroundColor: Background,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.data_usage_rounded),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    FadeRoute(
                      exitPage: CreateCasualPage(),
                      enterPage: Dashboardb(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
            title: RichText(
              text: TextSpan(style: TileHeader, text: 'Create Casual Group'),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                GroupIDBox(
                  color: Green,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Background,
                      child: Center(
                        child: Padding(
                          padding: spacer.x.xs,
                          child: Column(
                            children: [
                              Padding(
                                padding: spacer.top.sm,
                              ),
                              Form(
                                key: _formKey,
                                child: Padding(
                                  padding: spacer.x.xxl,
                                  child: Column(
                                    children: [
                                      TextEntryBox(
                                        text: "Group Name",
                                        obscureText: false,
                                        textController:
                                            writeGroupData.groupNameController,
                                      ),
                                      Padding(
                                        padding: spacer.y.xs,
                                        child: TextEntryBox(
                                          text: "Group Password",
                                          obscureText: true,
                                          textController: writeGroupData
                                              .groupPasswordController,
                                        ),
                                      ),
                                      TextEntryBox(
                                        text: "Verify Password",
                                        obscureText: true,
                                        textController: writeGroupData
                                            .verifyGroupPasswordController,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ActionButton(
                                success: _success,
                                paddingStart: spacer.x.xl + spacer.top.xxs,
                                text: "Create Casual Group",
                                function: () async {
                                  groupBlocSink.add(CreateCasualEvent());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
