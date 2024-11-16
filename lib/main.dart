import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:push_on_notification/home.dart';
import 'package:push_on_notification/memo_input_page.dart';
import 'package:push_on_notification/remaind_model.dart';
import 'package:push_on_notification/remiand_date_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  // FlutterLocalNotificationsPlugin()
  //   ..resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.requestNotificationsPermission()
  //   ..initialize(const InitializationSettings(
  //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //     iOS: DarwinInitializationSettings(),
  //   ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/memo_input': (BuildContext context) => new MemoInputPage(RemaindModel(
              title: "",
              memo: "",
            )),
        '/remaind_date': (BuildContext context) =>
            new RemiandDatePage(RemaindModel(
              title: "",
              memo: "",
            )),
      },
    );
  }
}
