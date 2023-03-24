import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:topup2p/main.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/globals.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> signOut(context) async {
  UserProvider userProvder = Provider.of<UserProvider>(context, listen: false);
  try {
    if (_auth.currentUser != null) {
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        if (kDebugMode) {
          print('not signed in with google $e');
        }
      }
      await _auth.signOut();

      Navigator.of(context).popUntil((route) => route.isFirst);
      itemsObjectList.clear();
      userProvder.clearUser();
      // Navigate to a new screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Topup2p(),
        ),
      );
      //optional
      //Restart.restartApp();
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (_) => const Topup2p()), (route) => false);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error signing out: $e');
    }
  }
}
