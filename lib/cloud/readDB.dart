import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:topup2p/user/widgets/seller/seller.dart';
import 'package:topup2p/global/globals.dart';

Future<List<Map<String, dynamic>>> readData() async {
  //iterating documents
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

  //iterating document fields
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
  return readDBMap;
}

Future<void> readSellerData(String gameName) async {
  //List<Map<String, dynamic>> gameShops = [];
  if (gameShopList.isNotEmpty) {
    gameShopList.clear();
  }
  try {
    await dbInstance
        .collection("seller_games_data")
        .doc(gameName)
        .get()
        .then((documentSnapshot) {
      Map<String, dynamic> documentData =
          documentSnapshot.data() as Map<String, dynamic>;
      documentData.forEach((field, value) {
        gameShopList.add({
          'shop-name': field,
          'game-rates': value['rates'],
          'mop': value['mop']
        });
      });
    });
  } catch (e) {
    print('error $e');
  }
  if (gameShopList.isNotEmpty) {
    sellerFlag = true;
  } else {
    sellerFlag = false;
  }
  // return gameShops;
}
