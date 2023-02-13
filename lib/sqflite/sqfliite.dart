import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:topup2p/cloud/readDB.dart';
import 'package:topup2p/global/globals.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.getInstance();
  DatabaseHelper.getInstance();

  factory DatabaseHelper() => _instance;
  String dbName = 'topup2p.db';

  static Database? _database;

  //get database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }


  //check if db exists
  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  Future<void> checkDatabase() async {
    if (await databaseExists(join(await getDatabasesPath(), dbName)) == false) {
      await _initDatabase();
    } else {
    }
  }

  //create database
  Future<Database> _initDatabase() async {
    Database db;
    String path = join(await getDatabasesPath(), dbName);
    if (!await databaseExists(path)) {
      print(path);
      db = await openDatabase(
        path,
        version: 1,
      );
      _createDb(db);
    } else {
      db = await openDatabase(
        path,
        version: 1,
      );
    }
    return db;
  }


  static void _createDb(Database db) async {
    print('_createDb');
    try {
      await db.transaction((txn) async {
        await txn.execute(
            'CREATE TABLE user (userID TEXT PRIMARY KEY,fname TEXT,lname TEXT)');
        await txn.execute(
            'CREATE TABLE user_game_data (gameID INTEGER PRIMARY KEY,name TEXT,image_banner TEXT,image TEXT,isFav INTEGER, userID TEXT, FOREIGN KEY (userID) REFERENCES user(userID))');
      });
    } catch (e) {
      print('_createDb error: $e');
    }
  }

  //check if user already exists
  Future<void> checkUserData() async {
    final _dbdb = await database;

    await _dbdb.transaction((txn) async {
      final result =
          await txn.query('user', where: 'userID = ?', whereArgs: [user!.uid]);
      if (result.isEmpty) {
        insertData();
      }
    });
  }

  //insert data database
  Future<void> insertData() async {
    var docSnapshot = await dbInstance.collection('users').doc('normal').get();
    if (docSnapshot.exists) {
      usersNormal = docSnapshot.data();
    }
    final db = await database;
    await db.transaction((transaction) async {
      await transaction.rawInsert(
        'INSERT INTO user(userID, fname, lname) VALUES("${user!.uid}", "${usersNormal?['${user!.uid}']['name']['first']}", "${usersNormal?['${user!.uid}']['name']['last']}")',
      );
      var gameDataMap = await readData();
      for (var map in gameDataMap) {
        //bool to int
        int isFavInt = map['isFav'] ? 1 : 0;
        Map<String, dynamic> mapWithInt = Map.from(map)
          ..['isFav'] = isFavInt
          ..['userID'] = "${user!.uid}";
        await transaction.insert('user_game_data', mapWithInt,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  //get data database

  Future<List<Map<String, dynamic>>> getUserGameData() async {
    print('get user game data');
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('user_game_data');
    return result;
  }

//TO IMPLEMENT BELOW
/*
  //update data database
  Future<void> updateData(String name, int value, int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE user SET fname = "$name", lname = $value WHERE id = $id',
      );
      await txn.rawUpdate(
        'UPDATE user_game_data SET name = "$name", value = $value WHERE id = $id',
      );
    });
  }

  //delete data database
  Future<void> deleteData(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawDelete(
        'DELETE FROM my_table WHERE id = $id',
      );
      await txn.rawDelete(
        'DELETE FROM my_table WHERE id = $id',
      );
    });
  }
  */

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    await deleteDatabase(path);
  }
}
