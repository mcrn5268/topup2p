import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/main.dart';
import 'package:topup2p/models/user_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/providers/user_provider.singleton.dart';

Future<void> signOut(context) async {
  await FirebaseAuth.instance.signOut();

  //UserProviderSingleton().getUserProvider().dispose();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const Topup2p(),
    ),
  );
}
