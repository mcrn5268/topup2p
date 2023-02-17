import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/main.dart';

class Logout {
  Future<void> signOut(context) async {
    await auth.signOut();
    if (userType == 'normal') {
      theMap.clear();
      favoritedList = null;
      favoritedItems.clear();
    } else if (userType == 'seller') {
      sellerData.clear();
    }
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
