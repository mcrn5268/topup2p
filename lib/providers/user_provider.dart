import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/cloud/firebase_options.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserProvider() {
    init();
  }

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void updateUser({String? name, String? type, String? image}) {
    if (_user != null) {
      _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          name: name ?? _user!.name,
          type: type ?? _user!.type,
          image: image ?? _user!.image);
      notifyListeners();
    }
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        print('User is signed in!');
        signIn(user);
      } else {
        print('User is currently signed out!');
      }
      try {
        print(
            'UserModel ${_user!.uid} ${_user!.name} ${_user!.email} ${_user!.type} ');
      } catch (e) {
        print('UserModel = null');
      }
      notifyListeners();
    });
  }

  Future<void> signIn(User? user) async {
    final firestoreUserData = await FirestoreService().read('users', user!.uid);
    final userData = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: firestoreUserData!['name'],
        //phoneNumber: _phoneNumberController.text,
        type: firestoreUserData['type'],
        image: firestoreUserData['image']);
    if (_user == null) {
      setUser(userData);
    }
  }
}
