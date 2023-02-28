import 'package:collection/collection.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/utilities/globals.dart';

List<Item> convertMapsToItems(List<Map<String, dynamic>> maps) {
  return maps.map((map) => Item.fromMap(map)).toList();
}

Item? getItemByName(String name) {
  return itemsObjectList.firstWhereOrNull((element) => element.name == name);
}

Payment? getPaymentByName(String name, List<Payment> payments) {
  return payments.firstWhereOrNull((element) => element.paymentname == name);
}
