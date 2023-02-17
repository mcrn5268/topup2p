import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:flutter/services.dart';

import '../global/globals.dart';

Future userDataFirestore(
    UserCredential userCredential, String Fname, String Lname) async {

  Future<void> batchWrite() async {
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
    };

    var userRef = dbInstance.collection("users").doc(userCredential.user!.uid);
    batch.set(userRef, user);
    
    var usertypeRef = dbInstance.collection("user_types").doc(userCredential.user!.uid);
    batch.set(usertypeRef, {'type': 'normal'});

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
