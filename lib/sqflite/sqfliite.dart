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
    print('get database');
    if (_database != null) {
      print('get database if');
      return _database!;
    } else {
      print('get database else');
      _database = await _initDatabase();
      return _database!;
    }
  }

  //check if db exists
  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  Future<void> checkDatabase() async {
    print('check database');
    if (await databaseExists(join(await getDatabasesPath(), dbName)) == false) {
      print('check database if');
      await _initDatabase();
    } else {
      print('check database else');
    }
  }

  //create database
  Future<Database> _initDatabase() async {
    Database db;
    String path = join(await getDatabasesPath(), dbName);
    print('init database $path');
    if (!await databaseExists(path)) {
      print('init database if');
      print(path);
      db = await openDatabase(
        path,
        version: 1,
      );
      _createDb(db);
    } else {
      print('init database else');
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
      print('create database try');
      await db.transaction((txn) async {
        print('create database transaction start');
        await txn.execute(
            'CREATE TABLE user (userID TEXT PRIMARY KEY,fname TEXT,lname TEXT)');
        await txn.execute(
            'CREATE TABLE user_games_data (gameID INTEGER PRIMARY KEY,name TEXT,image_banner TEXT,image TEXT,isFav INTEGER, userID TEXT, FOREIGN KEY (userID) REFERENCES user(userID))');
        print('create database transaction execute done');
      });
      print('create database transaction done');
    } catch (e) {
      print('_createDb error: $e');
    }
  }

  //check if user already exists
  Future<void> checkUserData() async {
    print('check user data');
    final _dbdb = await database;
    var result;
    await _dbdb.transaction((txn) async {
      result =
          await txn.query('user', where: 'userID = ?', whereArgs: [user!.uid]);
    });
    if (result.isEmpty) {
      print('check user data if');
      await insertData();
    }
  }

  //insert data database
  Future<void> insertData() async {
    print('insert data');
    var docSnapshot = await dbInstance.collection('users').doc('normal').get();
    if (docSnapshot.exists) {
      print('insert data if');
      usersNormal = docSnapshot.data();
    }
    final db = await database;
    try {
      var gameDataMap = await readData();
      print('insert data try');
      await db.transaction((transaction) async {
        print('insert data transaction execute1');
        print("ID: ${user!.uid}");
        print("FName: ${usersNormal?['name']['first']}");
        print("LName: ${usersNormal?['name']['last']}");
        await transaction.execute(
          'INSERT INTO user(userID, fname, lname) VALUES("${user!.uid}", "${usersNormal?['name']['first']}", "${usersNormal?['name']['last']}")',
        );
        print('insert data transaction execute1 done');
        print('insert data for loop outside');
        for (var map in gameDataMap) {
          print('insert data for loop inside');
          //bool to int
          int isFavInt = map['isFav'] ? 1 : 0;
          Map<String, dynamic> mapWithInt = Map.from(map)
            ..['isFav'] = isFavInt
            ..['userID'] = "${user!.uid}";
          await transaction.insert('user_games_data', mapWithInt,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        print('insert data for loop done');
      });
    } catch (e) {
      print('Error in transaction: $e');
    }
  }

  //get data database

  Future<List<Map<String, dynamic>>> getUserGameData() async {
    print('get user game data');
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('user_games_data');
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
        'UPDATE user_games_data SET name = "$name", value = $value WHERE id = $id',
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
