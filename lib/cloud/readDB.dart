import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global/globals.dart';

// Future readData() async {
//   //List<Map<String, dynamic>> listMap = [];
//   print("READ DATAAAAAAAAA");
//   final docRef =
//       await dbInstance.collection("user-games-data").doc(user!.uid).collection("games");
//   await docRef.get().then((querySnapshot) {
//     querySnapshot.docs.forEach((document) {
//       theMap.add({
//         "name": document.id,
//         "image_banner": document.data()['image_banner'],
//         "image": document.data()['image'],
//         "isFav": document.data()['isFav']
//       });
//     });
//   });

//   var docSnapshot = await dbInstance.collection('users').doc('normal').get();
//   if (docSnapshot.exists) {
//     usersNormal = docSnapshot.data();
//   }
// }

Future<List<Map<String, dynamic>>> readData() async {
  //List<Map<String, dynamic>> listMap = [];
  print("READ DATAAAAAAAAA");
  var docSnapshot = await dbInstance.collection('users').doc(user!.uid).get();
  if (docSnapshot.exists) {
    usersNormal = docSnapshot.data();
  }
  List<Map<String, dynamic>> readDBMap = [];
  final docRef = await dbInstance.collection("games_data");
  await docRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      readDBMap.add({
        "name": document.id,
        "image_banner": document.data()['image_banner'],
        "image": document.data()['image'],
      });
    });
  });

  // var docRef2 = FirebaseFirestore.instance.collection('user_games_data');
  // docRef2.doc(user!.uid).snapshots().listen((docSnapshot) {
  //   if (docSnapshot.exists) {
  //     Map<String, dynamic> data = docSnapshot.data()!;
  //     for (var map in readDBMap) {
  //       if()
  //     }
  //     // You can then retrieve the value from the Map like this:
  //     var name = data['name'];
  //   }
  // });

  await dbInstance
      .collection("user_games_data")
      .doc(user!.uid)
      .get()
      .then((documentSnapshot) {
    Map<String, dynamic> documentData =
        documentSnapshot.data() as Map<String, dynamic>;
    documentData.forEach((field, value) {
      for (var i = 0; i < readDBMap.length; i++) {
        if (readDBMap[i]["name"] == field) {
          readDBMap[i]["isFav"] = value;
        }
      }
    });
  });
  // var docSnapshot = await dbInstance.collection('users').doc('normal').get();
  // if (docSnapshot.exists) {
  //   usersNormal = docSnapshot.data();
  // }
  return readDBMap;
}
