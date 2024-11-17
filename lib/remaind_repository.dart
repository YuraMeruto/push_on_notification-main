import 'package:push_on_notification/remaind_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

class RemaindRepository {
  void test() async {
    var database = await getDatabase();
    Map<String, dynamic> record = {
      'memo': "test_memo",
      'remaind_datetime': DateTime.now(),
    };
    database.insert('remaind', record);
  }

  Future<int> insert(RemaindModel model) async {
    var database = await getDatabase();
    return await database.insert(
        'remaind', model.toMap(is_convert_datetime: true));
  }

  Future<void> update(RemaindModel model) async {
    var database = await getDatabase();
    database.update('remaind', model.toMap(is_convert_datetime: true),
        where: "id = ?", whereArgs: [model.id]);
  }

  Future<void> delete(RemaindModel model) async {
    var database = await getDatabase();
    database.delete('remaind', where: "id = ?", whereArgs: [model.id]);
  }

  Future<RemaindModel> getModel(int targetId) async {
    // ローカルから取得
    var database = await getDatabase();

    var results =
        await database.query('remaind', where: "id = ?", whereArgs: [targetId]);
    var ret = results.map((Map<String, dynamic> m) {
      int id = m["id"];
      String title = m['title'];
      String memo = m['memo'];
      DateTime? remaind_time = null;

      if (m["remaind_time"] != null) {
        remaind_time = DateTime.parse(m["remaind_time"]);
      }

      return RemaindModel(
        id: id,
        title: title,
        memo: memo,
        remindTime: remaind_time,
      );
    }).toList();
    return ret[0];
  }

  Future<List<RemaindModel>> getModelList() async {
    // ローカルから取得
    var database = await getDatabase();

    var results = await database.query('remaind');

    return results.map((Map<String, dynamic> m) {
      int id = m["id"];
      String title = m['title'];
      String memo = m['memo'];
      DateTime? remaind_time = null;
      int isRemind = m['is_remind'];

      if (m["remaind_time"] != "null") {
        remaind_time = DateTime.parse(m["remaind_time"]);
      }
      return RemaindModel(
        id: id,
        title: title,
        memo: memo,
        remindTime: remaind_time,
        is_remind: isRemind,
      );
    }).toList();
  }

  // void create(String name) async {
  //   var database = await getDatabase();
  //   Map<String, dynamic> record = {'name': name};
  //   database.insert('category', record);
  // }

  Future<Database> getDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + 'push_on_notification.db';
    return await openDatabase(path, version: 1, onOpen: (
      Database db,
    ) async {
      await db.execute('drop table  IF EXISTS remaind');

      await db.execute('CREATE TABLE IF NOT EXISTS remaind ('
          '  id INTEGER PRIMARY KEY AUTOINCREMENT,'
          '  title TEXT,'
          '  memo TEXT,'
          '  remaind_time Text,'
          '  is_remind INTEGER'
          ')');
    });
  }
}
