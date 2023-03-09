import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/user_provider.dart';

class SignIn_Google extends StatelessWidget {
  const SignIn_Google({super.key});

  @override
  Widget build(BuildContext context) {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            final GoogleSignInAccount? googleUser =
                await _googleSignIn.signIn();
            final GoogleSignInAuthentication googleAuth =
                await googleUser!.authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            await _auth.signInWithCredential(credential).then((value) {
              Provider.of<UserProvider>(context, listen: false)
                  .signIn(value.user);
            });
          },
          child: Container(
            width: 180,
            height: 38.92,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                    image: AssetImage('assets/images/google.png'))),
          ),
        ),
      ],
    );
  }
}
