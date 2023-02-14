import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:flutter/services.dart';

import '../global/globals.dart';

Future userDataFirestore(
    UserCredential userCredential, String Fname, String Lname) async {
  print('userDataFirestore');

  /* ------------- TEMPORARY --------------
  late final List<Map<String, dynamic>> GamesMap = [];

  final manifestContent = await rootBundle.loadString('AssetManifest.json');

  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final imagePaths = manifestMap.keys
      .where((String key) => key.contains('assets/gameslogos/'))
      .toList();
  final imagePathsBanner = manifestMap.keys
      .where((String key) => key.contains('assets/gameslogos-banner/'))
      .toList();

  for (int i = 0; i < GlobalValues.productItems.length; i++) {
    late final Map<String, dynamic> tempMap = {};
    tempMap['name'] = GlobalValues.productItems[i];
    tempMap['image'] = imagePaths[i];
    tempMap['image_banner'] = imagePathsBanner[i];
    //tempMap['isFav'] = false;
    GamesMap.add(tempMap);
  }
-----------------------------------------------
*/

  Future<void> batchWrite() async {
    print('batch write');
    final batch = dbInstance.batch();

    //user info
    final user = <String, dynamic>{
      "name": {
        // "first": Fname,
        // "last": Lname,
        "first": "Laf",
        "last": "Ly",
      },
      "email": userCredential.user!.email,
      "type": "normal"
    };

    var userRef = dbInstance.collection("users").doc(userCredential.user!.uid);
    batch.set(userRef, user);

    //user game data
    List<Map<String, dynamic>> gameData = [];
    for (var i = 0; i < productItems.length; i++) {
      final Map<String, dynamic> tempMap = {};
      //all false since it's register - first write to DB
      tempMap[productItems[i]] = false;
      gameData.add(tempMap);
    }

    for (var data in gameData) {
      var gameName = data.keys.first;
      var gameIsFav = data[gameName];

      var gamesRef = dbInstance
          .collection("user_games_data")
          .doc(userCredential.user!.uid);
      batch.set(gamesRef, {gameName: gameIsFav}, SetOptions(merge: true));
    }

    await batch.commit();
  }

  await batchWrite();
}
