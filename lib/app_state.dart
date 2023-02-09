import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

import 'firebase_options.dart';

//bool _loggedIn = false;

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  //bool get loggedIn => _loggedIn;
  bool get loggedIn => GlobalValues.isLoggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        //_loggedIn = true;
        GlobalValues.isLoggedIn = true;
      } else {
        GlobalValues.isLoggedIn = false;
        //_loggedIn = false;
      }
      notifyListeners();
    });
  }
}
