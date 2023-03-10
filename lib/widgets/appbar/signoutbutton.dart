import 'package:flutter/material.dart';
import 'package:topup2p/cloud/firebase_auth.dart';
import 'package:topup2p/widgets/show_dialog.dart';

class SignoutButton extends StatelessWidget {
  const SignoutButton({super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool? flag = await dialogBuilder(
            context, 'Sign out', 'Are you sure you want to sign out?');
        if (flag!) {
          // ignore: use_build_context_synchronously
          signOut(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.red)),
      ),
      child: Row(
        children: const <Widget>[
          Text(
            'Sign Out',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
