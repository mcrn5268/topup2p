import 'package:topup2p/sqflite/sqfliite.dart';

void updateDataInSqflite(String userID, String name, bool value) async {
  final db = await DatabaseHelper().database;
  await db.transaction((txn) async {
    await txn.rawUpdate(
        'UPDATE user_games_data SET isFav = "${value ? 1 : 0}" WHERE userID = "$userID" AND name = "$name"');
  });
}
