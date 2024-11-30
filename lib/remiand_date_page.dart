import 'package:flutter/material.dart';
import 'package:push_on_notification/remaind_model.dart';
import 'package:push_on_notification/remaind_repository.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:push_on_notification/alarm_permission.dart';
import 'package:push_on_notification/memo_input_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class RemiandDatePage extends StatefulWidget {
  RemiandDatePage(this.model);
  RemaindModel model;

  @override
  _RemainDatePage createState() => _RemainDatePage(this.model);
}

class _RemainDatePage extends State<RemiandDatePage>
    with TickerProviderStateMixin {
  _RemainDatePage(this.model);
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isError = false;
  DateFormat format = DateFormat('yyyy/MM/dd hh:mm');

  RemaindModel model;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // このように自分(State)をcreateStateしたWidget(StatefulWidget)
          // のフィールドにアクセスできる。
          title: Text("リマインドする日時を設定してください"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    var datetime = await showDatePicker(
                      context: context,
                      initialDate: model.remindTime != null
                          ? model.remindTime
                          : DateTime.now(), // 現在の日付をデフォルトに設定
                      firstDate: DateTime(2000), // 選択可能な最小の日付
                      lastDate: DateTime(2100),
                    );

                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: model.remindTime != null
                          ? TimeOfDay(
                              hour: model.remindTime!.hour,
                              minute: model.remindTime!.minute)
                          : TimeOfDay.now(),
                    );
                    setState(() {
                      model.remindTime = DateTime(
                          datetime!.year,
                          datetime.month,
                          datetime.day,
                          time!.hour,
                          time.minute);
                    });
                    _isError = false;

                    if (DateTime.now().isAfter(model.remindTime!)) {
                      _isError = true;
                      print("未来の日時を選択してください");
                      return;
                    }
                  },
                  child: const Text('日付選択'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text('戻る')),
                    ElevatedButton(
                        onPressed: () async {
                          var repository = new RemaindRepository();
                          if (model.id == null) {
                            model.id = await repository.insert(model);
                          } else {
                            repository.update(model);
                          }
                          print(model.remindTime);
                          await showNotification(model);
                          Navigator.of(context).pushReplacementNamed("/home");
                        },
                        child: Text('完了')),
                  ],
                ),
                _isError
                    ? Text("未来の日時を指定してください",
                        style: TextStyle(color: Colors.red))
                    : Text(""),
              ],
            ),
          ),
        ));
  }

  Future<void> showNotification(RemaindModel model) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      model.title,
      model.memo,
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    // 通知チャンネルの設定 (Android 8.0以上)
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      model.title,
      model.memo,
      description: 'your_channel_description', // チャンネルの説明
      importance: Importance.max, // 通知の重要度
      playSound: true, // サウンドを鳴らす
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    var localtion = tz.getLocation('Asia/Tokyo');
    var time = tz.TZDateTime.from(model.remindTime!, localtion);
    print(time);
    print(time.runtimeType);
    print("oooooo");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      model.id!,
      model.title,
      model.memo,
      time,
      notificationDetails,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );

    print("バックグラウンド通知がスケジュールされました");
  }
}
