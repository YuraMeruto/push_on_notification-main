import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:push_on_notification/alarm_permission.dart';
import 'package:push_on_notification/memo_input_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_on_notification/remaind_model.dart';
import 'package:push_on_notification/remaind_repository.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  var repository = new RemaindRepository();
  DateFormat format = DateFormat('yyyy/MM/dd hh:mm');
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
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
        title: Center(child: Text('メモ')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: FutureBuilder<List<RemaindModel>>(
          future: repository.getModelList(), // 非同期関数を指定
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // データの取得中
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // エラーが発生した場合
              return Text('エラーが発生しました: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // データが正常に取得できた場合
              // 日付をソート
              var isRemindList = snapshot.data!.where((element) {
                return element.is_remind == 1;
              }).toList();
              var isRemindNotList = snapshot.data!.where((element) {
                return element.is_remind == 0;
              }).toList();
              isRemindList
                  .sort((a, b) => a.remindTime!.compareTo(b.remindTime!));
              var sortList = isRemindNotList + isRemindList;
              return ListView.builder(
                  itemCount: sortList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(index.toString()),
                      onDismissed: (direction) async {
                        await cancelNotification(sortList[index]);
                        await repository.delete(sortList[index]);
                        setState(() {
                          sortList.removeAt(index); // リストからアイテムを削除
                        });
                      },
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MemoInputPage(sortList[index])));
                            },
                            child: Card(
                              color: (sortList[index].remindTime != null &&
                                      sortList[index]
                                          .remindTime!
                                          .isBefore(DateTime.now()))
                                  ? Colors.grey
                                  : Colors.white,
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: sortList[index].is_remind == 1
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: 8, top: 8),
                                            child: Text(format.format(
                                                sortList[index].remindTime!)))
                                        : Text(""),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(sortList[index].title),
                                  ),
                                  Divider(),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 8, bottom: 8),
                                    alignment: Alignment.centerLeft,
                                    child: Text(sortList[index].memo),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              // 予期しない状態
              return Text('データがありません');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MemoInputPage(new RemaindModel(
                        title: "",
                        memo: "",
                      ))));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> cancelNotification(RemaindModel model) async {
    flutterLocalNotificationsPlugin.cancel(model.id!);
  }
}
