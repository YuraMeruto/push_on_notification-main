import 'package:flutter/material.dart';
import 'package:push_on_notification/home.dart';
import 'package:push_on_notification/remaind_model.dart';
import 'package:push_on_notification/remiand_date_page.dart';

class MemoInputPage extends StatefulWidget {
  MemoInputPage(this.model);

  RemaindModel model;
  @override
  _MemoInputPage createState() => _MemoInputPage(this.model);
}

class _MemoInputPage extends State<MemoInputPage> {
  _MemoInputPage(this.model);
  TextEditingController _memoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  RemaindModel model;
  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: model.memo);
    _titleController = TextEditingController(text: model.title);
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'タイトルを記入',
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
                labelText: 'メモしたい内容を記入',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                model.memo = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    child: Text("戻る")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RemiandDatePage(this.model)));
                    },
                    child: Text("次へ"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
