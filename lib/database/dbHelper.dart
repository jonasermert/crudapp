import 'package:crudapp/model/gericht.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getDatabasesPath();
    _database = await openDatabase(
      path.join(directory, 'crudapp.db'),
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE gerichte (id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, beschreibung TEXT NOT NULL, preis REAL NOT NULL)',
      ),
    );
    return _database!;
  }

  Future<List<Gericht>> alle() async {
    final db = await database;
    final rows = await db.query('gerichte', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Gericht.fromMap).toList();
  }

  Future<void> speichern(Gericht gericht) async {
    final db = await database;
    if (gericht.id == null) {
      await db.insert('gerichte', gericht.toMap());
    } else {
      await db.update(
        'gerichte',
        gericht.toMap(),
        where: 'id = ?',
        whereArgs: [gericht.id],
      );
    }
  }

  Future<void> loeschen(int id) async {
    final db = await database;
    await db.delete('gerichte', where: 'id = ?', whereArgs: [id]);
  }
}
