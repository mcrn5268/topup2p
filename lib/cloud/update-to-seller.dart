import 'package:topup2p/cloud/download-image.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

Future<void> ToSeller(String storeName, String? url) async {
  theMap.clear();
  favoritedList = null;
  favoritedItems.clear();
  //--------firestore---------
  dbInstance.collection("users").doc(user!.uid).delete();
  dbInstance.collection("user_games_data").doc(user!.uid).delete();
  String assetsPath = 'assets/images/store-placeholder.png';
  if (url != null) {
    assetsPath = await ImagetoAssets(url);
  }

  Future<void> batchWrite() async {
    final batch = dbInstance.batch();

    //seller info
    final seller = <String, dynamic>{
      "email": user!.email,
      "image": assetsPath,
    };

    var userRef = dbInstance.collection("sellers").doc(storeName);
    batch.set(userRef, seller);

    //update normal to seller
    var usertyperef = dbInstance.collection("user_types").doc(user!.uid);
    batch.update(usertyperef, {"type": "seller"});

    await batch.commit();
  }

  await batchWrite();
  //

  //--------sqflite---------
  await DatabaseHelper().checkDatabase();
  await DatabaseHelper().checkUserData(storeName);
  //
}
