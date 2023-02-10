import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global/globals.dart';

Future readData() async {
  List<Map<String, dynamic>> listMap = [];
  print("READ DATAAAAAAAAA");
  final docRef = db
      .collection("user-games-data")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("games");
  docRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      listMap.add({
        "name": document.id,
        "image-banner": document.data()['image-banner'],
        "image": document.data()['image'],
        "isFav": document.data()['isFav']
      });
    });
  });
}
