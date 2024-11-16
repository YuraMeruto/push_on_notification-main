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
  @override
  void initState() {
    super.initState();
    // Timezoneの初期化
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              print(snapshot.data?.length!);
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MemoInputPage(snapshot.data![index])));
                        },
                        child: Card(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(format
                                    .format(snapshot.data![index].remindTime!)),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(snapshot.data![index].title),
                              ),
                              Divider(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(snapshot.data![index].memo),
                              ),
                            ],
                          ),
                        ),
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
}
