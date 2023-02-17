import 'package:flutter/material.dart';
import 'package:topup2p/user/widgets/login.dart';

class LogInButton extends StatelessWidget {
  const LogInButton({super.key});

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
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginPage(),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black)),
              ),
              child: Row(
                children: const <Widget>[
                  Text(
                    'Log In',
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
