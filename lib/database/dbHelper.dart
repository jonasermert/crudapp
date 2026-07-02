import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Database _db;

  initDb() async {
    String database = await getDatabasePath();
    String path = join(
      databasePath,
      "/Users/jonasermert/docker/sqlite/databases/crudapp.db",
    );

    var db = await openDatabase(path, version: 1, onCreate: onCreate);
    return db;
  }
}
