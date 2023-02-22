import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

    var usertypeRef =
        dbInstance.collection("user_types").doc(userCredential.user!.uid);
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

Future<void> sellerGamesData(
    String gameName, List<Map<String, dynamic>> ratesMap,
    {bool? update, String? status}) async {
  print('seller games data');
  //---------------sellers---------------
  final documentReference =
      FirebaseFirestore.instance.collection('sellers').doc(sellerData["sname"]);
  //---------------------update----------------------
  if (update == true) {
    dbInstance
        .runTransaction((transaction) async {
          // Check if the document already exists
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (snapshot.exists) {
            // If the document doesn't exist, create a new document with the 'games' field and its nested fields

            transaction.update(documentReference, {'games.$gameName': status});

            // transaction.update(
            //   documentReference,
            //   {
            //     'games': {gameName: 'enabled'}
            //   },
            // );
          } else {
            print('Document doesnt exist');
          }
        })
        .then((value) => print('Transaction completed successfully'))
        .catchError((error) => print('Transaction failed1: $error'));
  }
  //---------------------set----------------------
  else {
    dbInstance
        .runTransaction((transaction) async {
          // Check if the document already exists
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (snapshot.exists) {
            // If the document doesn't exist, create a new document with the 'games' field and its nested fields
            transaction.set(
                documentReference,
                {
                  'games': {gameName: 'enabled'}
                },
                SetOptions(merge: true));
          } else {
            print('Document doesnt exist');
          }
        })
        .then((value) => print('Transaction completed successfully'))
        .catchError((error) => print('Transaction failed1: $error'));
  }

//---------------seller-games-data---------------
  final documentReference2 =
      FirebaseFirestore.instance.collection('seller_games_data').doc(gameName);
  //---------------------update----------------------
  if (update == true) {
    dbInstance
        .runTransaction((transaction) async {
          transaction.update(documentReference2, {
            '${sellerData["sname"]}': {'status': status}
          });

          var updateMap = {'${sellerData["sname"]}.rates': {}};

          for (var index = 0; index < ratesMap.length; index++) {
            updateMap['${sellerData["sname"]}.rates']!['rate$index'] = {
              'php': ratesMap[index]['php'],
              'digGoods': ratesMap[index]['digGoods']
            };
          }

          transaction.update(documentReference2, updateMap);

          transaction.update(
            documentReference2,
            {'${sellerData["sname"]}.status': status},
          );
        })
        .then((value) => print('Transaction completed successfully'))
        .catchError((error) => print('Transaction failed2: $error'));
  }
  //---------------------set----------------------
  else {
    dbInstance
        .runTransaction((transaction) async {
          transaction.set(
              documentReference2,
              {
                '${sellerData["sname"]}': {'status': 'enabled'}
              },
              SetOptions(merge: true));
          for (var index = 0; index < threeMops.length; index++) {
            print('sellerData[index] ${sellerData[index]}');
            if (sellerData[threeMops[index]] == 'enabled') {
              transaction.set(
                  documentReference2,
                  {
                    '${sellerData["sname"]}': {
                      'mop': {'mop${index + 1}': threeMops[index]}
                    }
                  },
                  SetOptions(merge: true));
            }
          }
          for (var index = 0; index < ratesMap.length; index++) {
            transaction.set(
                documentReference2,
                {
                  '${sellerData["sname"]}': {
                    'rates': {
                      'rate$index': {
                        'php': ratesMap[index]['php'],
                        'digGoods': ratesMap[index]['digGoods']
                      }
                    }
                  }
                },
                SetOptions(merge: true));
          }
        })
        .then((value) => print('Transaction completed successfully'))
        .catchError((error) => print('Transaction failed2: $error'));
  }
}
