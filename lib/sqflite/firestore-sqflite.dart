import 'package:sqflite/sqflite.dart';
import 'package:topup2p/cloud/readDB.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkAndUpdateData() async {
  final Database db = await DatabaseHelper().database;
  //result = sqflite user_game_data
  final List<Map<String, dynamic>> result = await db.query('user_game_data');
  //{"id": {MAP MAP MAP}}
  Map<String, dynamic> sqfliteData = Map();
  result.forEach((item) {
    //sqflite game name
    sqfliteData[item['name']] = item;
  });

  //_docRef = firebase firestore user_game_data
  final _docRef = await FirebaseFirestore.instance.collection('user_game_data').doc(user!.uid).collection("games");
  await _docRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      //document.id = game name (firebase firestore)
      final gameID = document.id;
      final firestoreData = document.data();
      if (sqfliteData.containsKey(gameID)) {
        if (sqfliteData[gameID]['isFav'] != firestoreData['isFav']) {
          // update the specific value in SQLite
          db.update('user_game_data', {'isFav': firestoreData['isFav']},
              where: 'name = ? and userID = ?', whereArgs: [gameID, user!.uid]);
        }
      } else {
        // create a copy of firestore to SQLite
        db.insert('user_game_data', firestoreData);
      }
    });
  });
}
