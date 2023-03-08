import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/main.dart';
import 'package:topup2p/providers/user_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> signOut(context) async {
  try {
    if (_auth.currentUser != null) {
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print('not signed in with google $e');
      }
      await _auth.signOut();

      Provider.of<UserProvider>(context, listen: false).clearUser();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error signing out: $e');
    }
  }

  //optional
  //Restart.restartApp();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Topup2p()), (route) => false);
}
