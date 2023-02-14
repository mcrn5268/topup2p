import 'package:topup2p/global/globals.dart';

void updateDataInFirestore(String userID, String name, bool value) async {
  await dbInstance
      .collection('user_games_data')
      .doc(userID)
      .update({'$name': value});
}
