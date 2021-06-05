// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_bloc.dart';
import 'package:cuitt/features/user_auth/presentation/pages/introduction.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//TODO: organize imports, make exit button constant across all menu functions, fix top bar when scrolling on dashboard screen, update UI for create/join/view group pages, and settings
class Cuitt extends StatefulWidget {
  @override
  _CuittState createState() => _CuittState();
}

class _CuittState extends State<Cuitt> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<UserAuthBloc>(
        create: (BuildContext context) => UserAuthBloc(),
        child: IntroPagesCreate(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Cuitt());
}

//the static Method that can convert from unix timestamp to DateTime: DateTime.fromMillisecondsSinceEpoch(unixstamp);
//DS3231Time + 946684800 = UnixTime
//int unixTime;
//current_time + 946684800 = UnixTime
//hitTime = DateTime.fromMillisecondsSinceEpoch(UnixTime);
//overviewData.add(OData(hitTime,draw_length));
//convert graph domain to DateTime
//current viewport is DateTime now
//domain part of data is DateTime
