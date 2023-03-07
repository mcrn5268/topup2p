import 'package:flutter/foundation.dart';
import 'package:topup2p/models/item_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<Item> _favorites = [];

  List<Item> get favorites => _favorites;

  void toggleFavorite(Item item, {bool notify = true}) {
    if (_favorites.contains(item)) {
      _favorites.remove(item);
    } else {
      _favorites.add(item);
    }
    if (notify) {
      notifyListeners();
    }
  }

  bool isFavorite(Item item) {
    return _favorites.contains(item);
  }

  int indexOf(Item item) {
    return _favorites.indexOf(item);
  }

  void clearFavorites({bool notify = true}) {
    _favorites.clear();
    if (notify) {
      notifyListeners();
    }
  }

  void addItems(List<Item> items, {bool notify = true}) {
    _favorites.addAll(items);
    if (notify) {
      notifyListeners();
    }
  }
}
