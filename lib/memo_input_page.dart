import 'package:flutter/material.dart';
import 'package:push_on_notification/home.dart';
import 'package:push_on_notification/remaind_model.dart';
import 'package:push_on_notification/remiand_date_page.dart';
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

class MemoInputPage extends StatefulWidget {
  MemoInputPage(this.model);

  RemaindModel model;
  @override
  _MemoInputPage createState() => _MemoInputPage(this.model);
}

class _MemoInputPage extends State<MemoInputPage>
    with TickerProviderStateMixin {
  _MemoInputPage(this.model);
  TextEditingController _memoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isError = false;
  DateFormat format = DateFormat('yyyy/MM/dd hh:mm');

  RemaindModel model;
  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: model.memo);
    _titleController = TextEditingController(text: model.title);
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
  void dispose() {
    _memoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // このように自分(State)をcreateStateしたWidget(StatefulWidget)
        // のフィールドにアクセスできる。
        title: Text("メモを書いてください"),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'メモを記入',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    model.title = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _memoController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: '詳細を記入　',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    model.memo = value;
                  },
                ),
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

                    if (model.remindTime != null &&
                        DateTime.now().isAfter(model.remindTime!)) {
                      _isError = true;
                      print("未来の日時を選択してください");
                      return;
                    }
                  },
                  child: const Text('日付選択'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    model.remindTime == null
                        ? Text("")
                        : Text("設定した日付  " + format.format(model.remindTime!)),
                    model.remindTime == null
                        ? Container()
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                model.remindTime = null;
                              });
                            },
                            child: Text('クリア')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text('戻る')),
                    SizedBox(
                      width: 30,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var repository = new RemaindRepository();
                          model.is_remind = 1;
                          if (model.remindTime == null) {
                            model.is_remind = 0;
                          }
                          if (model.id == null) {
                            model.id = await repository.insert(model);
                          } else {
                            repository.update(model);
                          }
                          if (model.remindTime != null) {
                            if (model.memo.isEmpty) {
                              model.memo = " ";
                            }

                            await showNotification(model);
                          }
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
        ),
      ),
    );
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
