import 'package:flutter/material.dart';
import 'package:topup2p/screens/login.dart';

class LogInButton extends StatelessWidget {
  const LogInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      },
      
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.transparent),
          ),
      child: Row(
        children: const <Widget>[
          Text(
            'Log In',
          ),
        ],
      ),
    );
  }
}
