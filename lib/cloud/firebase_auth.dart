import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/main.dart';

Future<void> signOut(context) async {
  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const Topup2p(),
    ),
  );
}
