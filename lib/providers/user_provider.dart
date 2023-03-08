import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
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

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
  void updateUser(
      {String? name, String? type, String? image, String? image_url}) {
    if (_user != null) {
      _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          name: name ?? _user!.name,
          type: type ?? _user!.type,
          image: image ?? _user!.image,
          image_url: image_url ?? _user!.image_url);

      notifyListeners();
    }
  }

  Future<void> init() async {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        if (kDebugMode) {
          print('User is signed in!');
        }
        signIn(user);
      } else {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      }
      notifyListeners();
    });
  }

  Future<void> signIn(User? user) async {
    final firestoreUserData = await FirestoreService()
        .read(collection: 'users', documentId: user!.uid);
    final userData;
    if (firestoreUserData != null) {
      userData = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: firestoreUserData!['name'],
          //phoneNumber: _phoneNumberController.text,
          type: firestoreUserData['type'],
          image: firestoreUserData['image'],
          image_url: firestoreUserData['image_url']);
    } else {
      //reason for this is when a user logs in with google sign in
      //first time log in - need to create initial data to users collection
      //in firestore
      const String imagePlaceholderPath =
          'assets/images/person-placeholder.png';
      FirestoreService()
          .create(collection: 'users', documentId: user.uid, data: {
        'email': user.email,
        'image': imagePlaceholderPath,
        'image_url': imagePlaceholderPath,
        'name': user.displayName!,
        'type': 'normal'
      });
      userData = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName!,
          //phoneNumber: _phoneNumberController.text,
          type: 'normal',
          image: imagePlaceholderPath,
          image_url: imagePlaceholderPath);
    }

    if (_user == null) {
      setUser(userData);
    }
  }
}
