import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

import 'firebase_options.dart';

//bool _loggedIn = false;

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  //bool get loggedIn => _loggedIn;
  bool get loggedIn => isLoggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.authStateChanges().listen((userr) async {
      user = FirebaseAuth.instance.currentUser;
      if (userr != null) {
        //_loggedIn = true;
        await checkUserType();
        isLoggedIn = true;
        await DatabaseHelper().checkDatabase();
        await DatabaseHelper().checkUserData();
        await checkAndUpdateData();
      } else {
        isLoggedIn = false;
        //_loggedIn = false;
      }
      //if (_runCount != 1) {
      notifyListeners();
      //}
    });
  }
}

Future<void> checkUserType() async {
  var collection = dbInstance.collection('user_types');
  var docSnapshot = await collection.doc(user!.uid).get();
  if (docSnapshot.exists) {
    Map<String, dynamic> data = docSnapshot.data()!;
    userType = data['type'];
  }
}
