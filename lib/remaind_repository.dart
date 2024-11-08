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

  // void create(String name) async {
  //   var database = await getDatabase();
  //   Map<String, dynamic> record = {'name': name};
  //   database.insert('category', record);
  // }

  Future<Database> getDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + 'push_on_notification.db';
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS remaind ('
          '  id INTEGER PRIMARY KEY AUTOINCREMENT,'
          '  memo TEXT,'
          '  remaind_datetime Text'
          ')');
    });
  }
}
