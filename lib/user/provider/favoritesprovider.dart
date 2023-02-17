import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/updatefirestore.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/updatesqflite.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/favorites-widgets/favorites.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/favorites-widgets/favorites-items.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

int index = 0;

class FavoritesProvider with ChangeNotifier {
  String getImage(dynamic item) {
    return GlobalValues.forIcon[item]!;
  }

  void setImage(dynamic item) {
    item['isFav'] = !item['isFav'];
    if (item['isFav']) {
      GlobalValues.favoritedItems.add(FavoriteItems(
          item['name'], item['image'], item['isFav'], item['image_banner']));
    } else {
      GlobalValues.favoritedItems.removeWhere((i) => i.name == item['name']);
    }
    notifList();
    updateDataInSqflite(user!.uid, item['name'], item['isFav']);
    updateDataInFirestore(user!.uid, item['name'], item['isFav']);
  }

  void notifList() {
    notifyListeners();
  }
}
