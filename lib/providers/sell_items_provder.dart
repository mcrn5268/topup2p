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
    print('index $index');
    if (index != -1) {
      _Sitems[index][item] = status;
      notifyListeners();
    }
    print('test ${_Sitems[index][item]}');
  }

  void updateItemsList(List<Map<Item, String>> list) {
    bool flag = false;
    for (int i = 0; i < list.length; i++) {
      for (Item item in list[i].keys) {
        if (_Sitems[i][item] != list[i][item]) {
          _Sitems[i][item] = list[i][item]!;
          flag = true;
        }
      }
    }
    if (flag) {
      notifyListeners();
    }
  }

  void clearItems({bool notify = true}) {
    _Sitems.clear();
    if (notify) {
      notifyListeners();
    }
  }

  void addItems(List<Map<Item, String>> items, {bool notify = false}) {
    _Sitems.addAll(items);
    if (notify) {
      notifyListeners();
    }
  }

  void toggleAllGamesProvider(bool enable) {
    _Sitems.map((map) => map[map.keys.first] = enable ? 'enabled' : 'disabled')
        .toList();
    notifyListeners();
  }
}
