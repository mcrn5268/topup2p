import 'package:sqflite/sqflite.dart';
import 'package:topup2p/cloud/readDB.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkAndUpdateData() async {
  print('check and update');
  final db = await DatabaseHelper().database;
  //sqflite
  final result = await db
      .query('user_games_data', where: 'userID = ?', whereArgs: [user!.uid]);
  if (result.isNotEmpty) {
    print('result is not empty');
    // check if the local data is already up-to-date with Firestore
    var docSnapshot =
        await dbInstance.collection('user_games_data').doc(user!.uid).get();
    if (docSnapshot.exists) {
      print('doc exist');
      var userGD = docSnapshot.data() as Map<String, dynamic>;

      userGD.forEach((field, value) async {
        print('$field $value');
        for (var i = 0; i < result.length; i++) {
          if (result[i]['name'] == field) {
            print('if name == name $field');
            if (result[i]['isFav'] != value) {
              print('if isFav != value $value');
              await db.transaction((txn) async {
                print('trabsaction');
                await txn.rawUpdate(
                    'UPDATE user_games_data SET isFav = ? WHERE userID = ? AND name = ?',
                    [value ? 1 : 0, user!.uid, field]);
              });
            }
          }
        }
      });
    }
  } else {
    // if the data does not exist, insert the data
    await DatabaseHelper().insertData();
  }
}
