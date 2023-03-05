import 'dart:math';

//generate random ID for conversationID
String generateID() {
  final random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return String.fromCharCodes(Iterable.generate(
      10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

//map to list for shops that are enabled
List<Map> mapToList(Map<String, dynamic> map) {
  return map.entries
      .where((entry) => entry.value['info']['status'] == 'enabled')
      .map((entry) {
    return {
      'shop_name': entry.key,
      ...entry.value,
    };
  }).toList();
}
