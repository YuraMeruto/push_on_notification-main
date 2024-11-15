import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:push_on_notification/alarm_permission.dart';
import 'package:push_on_notification/memo_input_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    // Timezoneの初期化
    tz.initializeTimeZones();
    // WorkManagerの初期化
    // 通知の初期化
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Future<void> _showNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     showWhen: false,
  //   );

  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     '通知のタイトル',
  //     'これは通知の内容です',
  //     platformChannelSpecifics,
  //     payload: 'カスタムペイロード',
  //   );
  // }

  Future<void> showNotification() async {
//    openAppSettings();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    // 通知チャンネルの設定 (Android 8.0以上)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // チャンネルID
      'your_channel_name', // チャンネル名
      description: 'your_channel_description', // チャンネルの説明
      importance: Importance.max, // 通知の重要度
      playSound: true, // サウンドを鳴らす
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    // await flutterLocalNotificationsPlugin.show(
    //     0, 'plain title', 'plain body', notificationDetails,
    //     payload: 'item x');

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    var localtion = tz.getLocation('Asia/Tokyo');
    var time1 = tz.TZDateTime.now(localtion);
    time1 = time1.add(Duration(seconds: 5));
    print(time1);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '通知タイトル',
      '通知内容',
      time1,
      notificationDetails,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );

    time1 = tz.TZDateTime.now(localtion);
    time1 = time1.add(Duration(seconds: 10));
    print(time1);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '通知タイトル02',
      '通知内容02',
      time1,
      notificationDetails,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );

    print("バックグラウンド通知がスケジュールされました");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
//          showLocalNotification('Notification title', 'Notification message');
          showNotification();
//          await AlarmPermission.requestExactAlarmPermission();
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => MemoInputPage()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
