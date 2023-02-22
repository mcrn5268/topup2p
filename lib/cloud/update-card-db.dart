import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

Future<bool> checkRowExists(String name) async {
  var db = await DatabaseHelper().database;
  var result = await db.query('seller_mop_data',
      where: 'sellerID = ? AND mop_name = ?',
      whereArgs: ['${user!.uid}', name]);
  return result.isNotEmpty;
}

Future<void> updateOrInsertRow(String name) async {
  var db = await DatabaseHelper().database;

  if (await checkRowExists(name)) {
    await db.update(
        'seller_mop_data',
        {
          'mop_status': sellerData['$name'],
          'account_name': sellerData['${name}name'] ?? '',
          'account_number': sellerData['${name}num'] ?? ''
        },
        where: 'sellerID = ? AND mop_name = ?',
        whereArgs: ['${user!.uid}', '$name']);
  } else {
    await db.insert('seller_mop_data', {
      'sellerID': '${user!.uid}',
      'mop_name': name,
      'mop_status': sellerData['$name'],
      'account_name': sellerData['${name}name'] ?? '',
      'account_number': sellerData['${name}num'] ?? ''
    });
  }
}

Future<void> updateSellerFirestore() async {
  final docRef = dbInstance.collection('sellers').doc(sellerData["sname"]);

  dbInstance
      .runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception("Document does not exist");
        }
        final data = doc.data()!;
        for (var item in threeMops) {
          //if (data.containsKey('MoP') || data['MoP'].containsKey(item)) {

          transaction.set(
              docRef,
              {
                'MoP': {
                  item: {'account_name': sellerData['${item}name'] ?? ''}
                }
              },
              SetOptions(merge: true));
          transaction.set(
              docRef,
              {
                'MoP': {
                  item: {'account_number': sellerData['${item}num'] ?? ''}
                }
              },
              SetOptions(merge: true));
          transaction.set(
              docRef,
              {
                'MoP': {
                  item: {'status': sellerData['${item}'] ?? ''}
                }
              },
              SetOptions(merge: true));
          //}
        }

        return 'Subfield check complete';
      })
      .then((result) => print('Transaction success: $result'))
      .catchError((error) => print('Transaction failure: $error'));
}
