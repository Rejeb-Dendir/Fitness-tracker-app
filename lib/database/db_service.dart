import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const dbname = "data.db";
  static const dbversion = 1;
  static const tablename = "ActTable";
  static const columnId = "columnId";
  static const type = "type";
  static const data = "data";
  static const date = "date";

//singleton
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  //initialize database
  static Database? database;
  Future<Database?> get db async {
    if (database != null) {
      return database;
    }
    database = await initializeDatabase();
    return database!;
  }

  initializeDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, dbname);
    return await openDatabase(path, version: dbversion, onCreate: createTable);
  }

  createTable(Database db, int version) {
    db.execute("CREATE TABLE IF NOT EXISTS $tablename ("
        "$columnId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$type TEXT NOT NULL,"
        "$data REAL NOT NULL,"
        "$date Text NOT NULL"
        ");");
    return db;
  }

  Future<int?> addActivity(Map<String, dynamic> row) async {
    Database? db = await instance.db;
    if (db != null) {
      return db.insert(tablename, row);
    }
    return null;
  }

  Future<List<Map<String, Object?>>> getActivities(String category) async {
    Database? db = await instance.db;
    if (db != null) {
      if (category == "All") {
        return await db.rawQuery('SELECT * FROM ActTable');
      } else {
        return await db.rawQuery(
            'SELECT * FROM ActTable WHERE type =?', [category.toLowerCase()]);
      }
    }
    return [];
  }

  Future<int> deleteActivity(int id) async {
  Database? db = await instance.db;
  if (db != null) {
    return await db.delete(
      tablename,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  return 0;
}
}
