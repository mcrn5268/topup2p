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
    }
    if (userType == 'seller') {
      final db = await openDatabase(dbName);
      final tableNames = ['user', 'seller'];
      if (await doTablesExist(db, tableNames) == false) {
        await await openDatabase(
          join(await getDatabasesPath(), dbName),
          version: 1,
        );
        _createDb(db);
      }
    }
  }

  Future<bool> doTablesExist(Database db, List<String> tableNames) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN (${tableNames.map((name) => "'$name'").join(', ')})");
    return result.length == tableNames.length;
  }

  //create database
  Future<Database> _initDatabase() async {
    Database db;
    String path = join(await getDatabasesPath(), dbName);
    if (!await databaseExists(path)) {
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
    try {
      await db.transaction((txn) async {
        if (userType == 'normal') {
          //normal user
          await txn.execute(
              'CREATE TABLE user (userID TEXT PRIMARY KEY,fname TEXT,lname TEXT)');
          await txn.execute(
              'CREATE TABLE user_games_data (gameID INTEGER PRIMARY KEY,name TEXT,image_banner TEXT,image TEXT,isFav INTEGER, userID TEXT, FOREIGN KEY (userID) REFERENCES user(userID))');
        } else if (userType == 'seller') {
          //seller

          //seller basic infos
          await txn.execute(
              'CREATE TABLE seller (sellerID TEXT PRIMARY KEY,sname TEXT,email TEXT, image TEXT)');
          //seller games selling
          // await txn.execute(
          //     'CREATE TABLE seller_data (sellergameID INTEGER PRIMARY KEY,name TEXT,image_banner TEXT,image TEXT, sellerID TEXT, FOREIGN KEY (sellerID) REFERENCES seller(sellerID))');
          //seller mop list
          await txn.execute(
              'CREATE TABLE seller_mop_data (mopID INTEGER PRIMARY KEY,mop_status TEXT,mop_name TEXT,account_name TEXT,account_number INTEGER, sellerID TEXT, FOREIGN KEY (sellerID) REFERENCES seller(sellerID))');
          //seller games rates list
          await txn.execute(
              'CREATE TABLE seller_games_rate_data (sellerrateID INTEGER PRIMARY KEY,gamename TEXT,rate1 TEXT,rate2 TEXT,rate3 TEXT,rate4 TEXT,rate5 TEXT,rate6 TEXT, sellerID TEXT, FOREIGN KEY (sellerID) REFERENCES seller(sellerID))');
        }
      });
    } catch (e) {}
  }

// if (userType == 'normal') {
//           //normal
// }else if (userType == 'seller') {
//           //seller
// }
  //check if user already exists
  Future<void> checkUserData([String? storeName]) async {
    final _dbdb = await database;
    var result;
    if (userType == 'normal') {
      //normal
      await _dbdb.transaction((txn) async {
        result = await txn
            .query('user', where: 'userID = ?', whereArgs: ['${user!.uid}']);
      });
    } else if (userType == 'seller') {
      //seller
      await _dbdb.transaction((txn) async {
        result = await txn.query('seller',
            where: 'sellerID = ?', whereArgs: ['${user!.uid}']);
      });
    }

    if (result.isEmpty) {
      await insertData(storeName);
    }
  }

  //insert data database
  Future<void> insertData([String? storeName]) async {
    final db = await database;
    if (userType == 'normal') {
      //normal
      var docSnapshot =
          await dbInstance.collection('users').doc(user!.uid).get();
      try {
        var gameDataMap = await readData();
        await db.transaction((transaction) async {
          await transaction.execute(
            'INSERT INTO user(userID, fname, lname) VALUES("${user!.uid}", "${docSnapshot.data()?['name']['first']}", "${docSnapshot.data()?['name']['last']}")',
          );
          for (var map in gameDataMap) {
            //bool to int
            int isFavInt = map['isFav'] ? 1 : 0;
            Map<String, dynamic> mapWithInt = Map.from(map)
              ..['isFav'] = isFavInt
              ..['userID'] = "${user!.uid}";
            await transaction.insert('user_games_data', mapWithInt,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        });
      } catch (e) {
        print('Error in transaction1: $e');
      }
    } else if (userType == 'seller') {
      //seller
      var docSnapshot =
          await dbInstance.collection('sellers').doc(storeName).get();
      try {
        await db.transaction((transaction) async {
          await transaction.execute(
            'INSERT INTO seller(sellerID, sname, email, image) VALUES("${user!.uid}", "$storeName", "${docSnapshot.data()?['email']}", "${docSnapshot.data()?['image']}")',
          );
        });
      } catch (e) {
        print('Error in transaction2: $e');
      }
    }
  }

  //get data database

  Future<List<Map<String, dynamic>>> getUserGameData() async {
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

