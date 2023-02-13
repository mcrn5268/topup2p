import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

Future<void> getSqfliteData() async {
  print('sqflite to global ${user!.uid}');
  final db = await DatabaseHelper().database;
  final result = await db
      .query('user_game_data', where: 'userID = ?', whereArgs: [user!.uid]);
  List<Map<String, dynamic>> resultList = result.cast<Map<String, dynamic>>();
  for (var i = 0; i < resultList.length; i++) {
    Map<String, dynamic> tempMap = Map.of(resultList[i]);
    tempMap['isFav'] = tempMap['isFav'] == 0 ? false : true;
    theMap.add(tempMap);
  }
}

Future<List<Map<String, dynamic>>> getAllData() async {
  final db = await DatabaseHelper().database;
  final result = await db.query('user_game_data');
  return result;
}
