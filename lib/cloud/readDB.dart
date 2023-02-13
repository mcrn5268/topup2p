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

  List<Map<String, dynamic>> readDBMap = [];
  final docRef =
      await dbInstance.collection("user-games-data").doc(user!.uid).collection("games");
  await docRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      readDBMap.add({
        "name": document.id,
        "image_banner": document.data()['image_banner'],
        "image": document.data()['image'],
        "isFav": document.data()['isFav']
      });
    });
  });

  // var docSnapshot = await dbInstance.collection('users').doc('normal').get();
  // if (docSnapshot.exists) {
  //   usersNormal = docSnapshot.data();
  // }
  return readDBMap;
}
