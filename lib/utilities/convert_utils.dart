// List<Map<dynamic, dynamic>> mapToList(Map<String, dynamic> map) {
//   return map.entries.map((entry) {
//     return {
//       'shop_name': entry.key,
//       ...entry.value,
//     };
//   }).toList();
// }
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
