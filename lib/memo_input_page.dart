import 'package:flutter/material.dart';
import 'package:push_on_notification/home.dart';
import 'package:push_on_notification/remiand_date_page.dart';

class MemoInputPage extends StatefulWidget {
  @override
  _MemoInputPage createState() => _MemoInputPage();
}

class _MemoInputPage extends State<MemoInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'メモしたい内容を記入',
                border: OutlineInputBorder(),
              ),
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
                              builder: (context) => RemiandDatePage()));
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
