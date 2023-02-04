import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites-items.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

int index = 0;

class FavoritesProvider extends ChangeNotifier {
  String getImage(dynamic item) {
    return GlobalValues.forIcon[item]!;
  }

  void setImage(dynamic item) {
    item['isFav'] = !item['isFav'];
    if (item['isFav']) {
      GlobalValues.favoritedItems
          .add(FavoriteItems(item['name'], item['image'], item['isFav']));
    } else {
      GlobalValues.favoritedItems.removeWhere((i) => i.name == item['name']);
    }
    notifList();
  }

  void notifList() {
    notifyListeners();
  }
}