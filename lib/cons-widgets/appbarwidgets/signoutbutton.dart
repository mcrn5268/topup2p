import 'package:flutter/material.dart';

import '../../user/logout.dart';

class SignoutButton extends StatelessWidget {
  const SignoutButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _dialogBuilder(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.red)),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Sign Out',
                    style:
                        TextStyle(color:Colors.red ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Logout().signOut(context);
              },
            ),
          ],
        );
      },
    );
  }
}
