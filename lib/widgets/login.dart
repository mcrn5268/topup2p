// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:topup2p/widgets/customdivider.dart';
import 'package:topup2p/widgets/register.dart';
import 'package:topup2p/widgets/forgotpassword.dart';
import 'package:topup2p/widgets/mainpage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget loginSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
            obscureText: true,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Sign in',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      //Icon(Icons.arrow_forward_ios_outlined)
                      //animate arrow to moving
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );

    Widget forgotPassword = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black),
                children: const [
                  TextSpan(
                    text: 'Forgot password?',
                    //recognizer: TapGestureRecognizer()..onTap = () => const ForgotPage(),
                    // recognizer: TapGestureRecognizer()
                    //   ..onTap = () {
                    //     print('Forgot Password');
                    //     const ForgotPage();
                    //   },
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPage()));
              //MaterialPageRoute(builder: (context) => const SecondRoute()),
            },
          ),
        ],
      ),
    );
    Widget loginWith = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google.png',
              width: 180,
            ),
          ],
        ),
      ],
    );
    Widget signupSection = Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black),
                text: "Don't have an account?",
                children: const [
                  TextSpan(
                    text: ' Sign up ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const RegisterPage()));
              //MaterialPageRoute(builder: (context) => const SecondRoute()),
            },
          ),
        ],
      ),
    );
    Widget skipButton = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                //skip
              },
              child: Row(
                children: const <Widget>[
                  Text(
                    'Skip',
                  ),
                  Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            )
          ],
        ),
      ],
    );
    return Scaffold(
      body: ListView(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                skipButton,
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 700,
                ),
                loginSection,
                forgotPassword,
                const CustomDivider(),
                loginWith,
                signupSection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
