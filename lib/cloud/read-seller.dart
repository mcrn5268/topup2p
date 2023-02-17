import 'package:sqflite/sqflite.dart';
import 'package:topup2p/global/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

Future<void> checkAndUpdateData() async {
  final db = await DatabaseHelper().database;
  //sqflite
  final result = await db
      .query('user_games_data', where: 'userID = ?', whereArgs: [user!.uid]);
  if (result.isNotEmpty) {
    // check if the local data is already up-to-date with Firestore
    var docSnapshot =
        await dbInstance.collection('user_games_data').doc(user!.uid).get();
    if (docSnapshot.exists) {
      var userGD = docSnapshot.data() as Map<String, dynamic>;

      userGD.forEach((field, value) async {
        for (var i = 0; i < result.length; i++) {
          if (result[i]['name'] == field) {
            if (result[i]['isFav'] != value) {
              await db.transaction((txn) async {
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
