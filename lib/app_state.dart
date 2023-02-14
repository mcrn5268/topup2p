import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

import 'firebase_options.dart';

//bool _loggedIn = false;

class ApplicationState extends ChangeNotifier {
  int _runCount = 0;
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

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        //_loggedIn = true;
        GlobalValues.isLoggedIn = true;
        await DatabaseHelper().checkDatabase();
        await DatabaseHelper().checkUserData();
        await checkAndUpdateData();
      } else {
        GlobalValues.isLoggedIn = false;
        //_loggedIn = false;
      }
      _runCount++;
      //if (_runCount != 1) {
      notifyListeners();
      //}
    });
  }
}
