import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/main.dart';

class Logout {
  Future<void> signOut(context) async {
    await FirebaseAuth.instance.signOut();
    GlobalValues.theMap.clear();
    GlobalValues.favoritedList = null;
    GlobalValues.favoritedItems.clear();
    //Navigator.of(context).popUntil((route) => route.isFirst);
    //Navigator.pop(context);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) => const Topup2p(),
      ),
      (_) => false,
    );
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (_) => const Topup2p(),
    //   ),
    // );

    // Navigator.pushReplacement(
    //   MaterialPageRoute(builder: (BuildContext context) => const Topup2p()));
  }
}
