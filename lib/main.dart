// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:cron/cron.dart';
import 'package:cuitt/features/connect_device/data/datasources/user_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_bloc.dart';
import 'package:cuitt/features/user_auth/presentation/pages/introduction.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        child: IntroPages(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'users-database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      // Run the CREATE TABLE statement on the database.

      await db.execute(
        'CREATE TABLE userstats(id INTEGER PRIMARY KEY, userid STRING, count INTEGER, drawLengthTotal DOUBLE, drawLengthTotalYest DOUBLE, drawLengthTotalAverage DOUBLE, drawLengthTotalAverageYest DOUBLE, drawLengthAverage DOUBLE, drawLengthAverageYest DOUBLE, timeBetweenAverage DOUBLE)',
      );

      await db.execute(
        'CREATE TABLE userhour(id INTEGER PRIMARY KEY, userid STRING, drawLength DOUBLE, hour INTEGER)',
      );

      await db.execute(
        'CREATE TABLE userday(id INTEGER PRIMARY KEY, userid STRING, drawLength DOUBLE, day INTEGER)',
      );

      await db.execute(
        'CREATE TABLE usermonth(id INTEGER PRIMARY KEY, userid STRING, drawLength DOUBLE, month INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  var cron = new Cron();
  cron.schedule(new Schedule.parse('0 0 * 0 0'), () async {
    drawCount = 0;
    drawLengthTotal = 0;
    countWindow.insert(0, drawCount);
    totalWindow.insert(0, drawLengthTotal);
    if (countWindow.length > 14) {
      countWindow.removeLast();
      totalWindow.removeLast();
    }
    //TODO update stats
  });

  userDatabase = database;
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
