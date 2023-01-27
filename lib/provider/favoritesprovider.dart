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
    notifyListeners();
  }

  void checkNav() {
    // if ((size.width / 114.5).floor() > GlobalValues.favoritedList.length) {
    //   RVisible = false;
    // } else if ((size.width / 114.5).floor() <
    //     GlobalValues.favoritedList.length) {
    //   RVisible = true;
    // }

    // print((GlobalValues.favoritedItems.length + 1) * 114.5 > size.width);
    // print(GlobalValues.favoritedItems.length +1 );
    // if ((GlobalValues.favoritedItems.length) * 114.5 > size.width) {
    //   RVisible = true;
    //   notifyListeners();
    // } 
    //else {
    //   RVisible = false;
    //   notifyListeners();
    // }
  }
}
