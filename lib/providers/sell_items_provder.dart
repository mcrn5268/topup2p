// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:topup2p/models/item_model.dart';

class SellItemsProvider with ChangeNotifier {
  final List<Map<Item, String>> _Sitems = [];

  List<Map<Item, String>> get Sitems => _Sitems;

  void addItem(Item item, String status, {bool notify = true}) {
    _Sitems.add({item: status});
    if (notify) {
      notifyListeners();
    }
  }

  bool itemExist(Item item) {
    return _Sitems.any((map) => map.containsKey(item));
  }

  void updateItem(Item item, String status) {
    final index = _Sitems.indexWhere((map) => map.containsKey(item));
    if (index != -1) {
      _Sitems[index][item] = status;
      notifyListeners();
    }
  }

  void clearItems() {
    _Sitems.clear();
    notifyListeners();
  }

  void addItems(List<Map<Item, String>> items, {bool notify = false}) {
    _Sitems.addAll(items);
    if (notify) {
      notifyListeners();
    }
  }
}
