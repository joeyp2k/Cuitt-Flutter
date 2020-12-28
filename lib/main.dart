// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cuitt/presentation/pages/introduction.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//TODO: organize imports


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
      home: introPages,
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
