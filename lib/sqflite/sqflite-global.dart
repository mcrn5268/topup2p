import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

Future<void> getSqfliteData() async {
  var docSnapshot = await dbInstance.collection('users').doc(user!.uid).get();
  if (docSnapshot.exists) {
    usersInfo = docSnapshot.data();
  }
  final db = await DatabaseHelper().database;
  final result = await db.query('user_games_data',
      where: 'userID = ?', whereArgs: ['${user!.uid}']);
  List<Map<String, dynamic>> resultList = result.cast<Map<String, dynamic>>();
  for (var i = 0; i < resultList.length; i++) {
    Map<String, dynamic> tempMap = Map.of(resultList[i]);
    tempMap['isFav'] = tempMap['isFav'] == 0 ? false : true;
    tempMap['popularity'] = productItems.indexOf(tempMap['name']);
    theMap.add(tempMap);
  }
}

Future<List<Map<String, dynamic>>> getAllData() async {
  final db = await DatabaseHelper().database;
  final result = await db.query('user_games_data');
  return result;
}

Future<void> getSellerSqfliteData() async {
  print('getSellerSqfliteData1');
  final db = await DatabaseHelper().database;
  print('getSellerSqfliteData2');
  final result = await db
      .query('seller', where: 'sellerID = ?', whereArgs: ['${user!.uid}']);
  print('getSellerSqfliteData3');
  if (result.isNotEmpty) {
    final row = result.first;
    final map = <String, String>{};
    for (final column in row.keys) {
      final value = row[column].toString();
      map[column] = value;
    }
    sellerData = map;
  }
  final result2 = await db.query('seller_mop_data',
      columns: ['mop_status', 'mop_name', 'account_name', 'account_number'],
      where: 'sellerID = ?',
      whereArgs: ['${user!.uid}']);
  if (result2.isNotEmpty) {
    result2.forEach((row) {
      sellerData["${row['mop_name']}"] = row['mop_status'];
      sellerData["${row['mop_name']}name"] = row['account_name'];
      sellerData["${row['mop_name']}num"] = row['account_number'].toString();
    });
  } else {
    sellerData['GCash'] = 'disabled';
    sellerData['UnionBank'] = 'disabled';
    sellerData['Metrobank'] = 'disabled';
  }
}
