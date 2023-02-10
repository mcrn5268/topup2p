import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:flutter/services.dart';

import '../global/globals.dart';

Future initImages(
    UserCredential userCredential, String Fname, String Lname) async {
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
    tempMap['image-banner'] = imagePathsBanner[i];
    tempMap['isFav'] = false;
    GamesMap.add(tempMap);
  }

  // final alovelaceDocumentRef = db.collection("users").doc("alovelace");
  // final usersCollectionRef = db.collection("users");
  //final aLovelaceDocRef = db.doc("users/alovelace");

  //----------------firebase firestore---------

  Future<void> batchWrite() async {
    final batch = db.batch();

    //user info
    final user = <String, dynamic>{
      userCredential.user!.uid: {
        "name": {
          "first": Fname,
          "last": Lname,
        },
        "email": userCredential.user!.email
      }
    };

    var userRef = db.collection("users").doc("normal");
    batch.set(userRef, user);

    //user game data
    for (var data in GamesMap) {
      Map<String, dynamic> gameData = {
        "image": data["image"],
        "image-banner": data["image-banner"],
        "isFav": data["isFav"]
      };
      var gamesRef = db
          .collection("user-games-data")
          .doc(userCredential.user!.uid)
          .collection("games")
          .doc(data['name']);
      batch.set(gamesRef, gameData);
    }

    await batch.commit();
  }

  await batchWrite();
// Add a new document with a generated ID
  // db.collection("users").add(user).then((DocumentReference doc) =>
  //     print('DocumentSnapshot added with ID: ${doc.id}'));

  //----------------realtime database---------

  //write users info to realtime database
  // DatabaseReference accountReg =
  //     FirebaseDatabase.instance.ref().child("users/normal");

  // await accountReg.set({
  //   userCredential.user!.uid: {
  //     "name": name,
  //     "email": userCredential.user!.email
  //   }
  // });

  // //write json to database initial games data
  // for (Map<String, dynamic> item in GamesMap) {
  //   Map<String, dynamic> gameData = {
  //     "image": item["image"],
  //     "image-banner": item["image-banner"],
  //     "isFav": item["isFav"]
  //   };
  //   FirebaseDatabase.instance
  //       .ref("games/${userCredential.user!.uid}/${item["name"]}")
  //       .set(gameData);
  // }
}
