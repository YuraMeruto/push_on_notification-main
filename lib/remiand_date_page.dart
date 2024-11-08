import 'package:flutter/material.dart';

class RemiandDatePage extends StatefulWidget {
  @override
  _RemainDatePage createState() => _RemainDatePage();
}

class _RemainDatePage extends State<RemiandDatePage>
    with TickerProviderStateMixin {
  DateTime? _pushTime;

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
                      initialDate: DateTime(DateTime.now().year - 10),
                      firstDate: DateTime(DateTime.now().year - 100),
                      lastDate: DateTime(DateTime.now().year),
                    );

                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      _pushTime = DateTime(datetime!.year, datetime.month,
                          datetime.day, time!.hour, time.minute);
                    });
                    print(_pushTime);
                  },
                  child: const Text('日付選択'),
                ),
                Text("設定した日付" + _pushTime.toString()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(onPressed: () {}, child: Text('戻る')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed("/home");
                        },
                        child: Text('完了')),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
