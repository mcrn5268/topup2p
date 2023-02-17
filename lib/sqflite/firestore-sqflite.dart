import 'package:sqflite/sqflite.dart';
import 'package:topup2p/cloud/readDB.dart';
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
                    [value ? 1 : 0, '${user!.uid}', field]);
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

Future<void> checkAndUpdateDataSeller() async {
  
  final doc =
      await dbInstance.collection('sellers').doc(sellerData["sname"]).get();
  final db = await DatabaseHelper().database;
  final result = await db.rawQuery(
      'SELECT mop_name, account_name, account_number FROM seller_mop_data WHERE sellerID = "${user!.uid}"');
  if (result.isNotEmpty) {
    for (var i = 0; i < threeMops.length; i++) {
      final firestoreValue1 = doc.get('MoP.${threeMops[i]}.account_name');
      final firestoreValue2 = doc.get('MoP.${threeMops[i]}.account_num');

      final mop_name = result[i]['mop_name'];
      final accont_name = result[i]['account_name'];
      final accont_num = result[i]['account_number'];

      if (firestoreValue1 != accont_name || firestoreValue2 != accont_num) {
        // The data needs to be updated

        // Execute an UPDATE statement to update the corresponding columns in the SQLite database with the values from the Firestore document
        await db.rawQuery(
            'UPDATE seller_mop_data SET account_name = ?, account_number = ? WHERE sellerID = ?',
            [firestoreValue1, firestoreValue2, '${user!.uid}']);
      }
    }
  }

}
