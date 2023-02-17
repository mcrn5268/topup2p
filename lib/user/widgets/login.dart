// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqfliite.dart';
import 'package:topup2p/sqflite/sqflite-global.dart';
import 'package:topup2p/cons-widgets/customdivider.dart';
import 'package:topup2p/user/widgets/register.dart';
import 'package:topup2p/user/widgets/forgotpassword.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/mainpage.dart';

import '../logout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _pass = TextEditingController();
  String? _errorText;
  String? _errorText2;
  @override
  Widget build(BuildContext context) {
    Widget loginSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _email,
            decoration: InputDecoration(
              hintText: 'Email',
              errorText: _errorText,
            ),
            onChanged: (textt) {
              setState(() {
                _errorText = null;
              });
            },
          ),
          TextFormField(
            controller: _pass,
            decoration: InputDecoration(
              hintText: 'Password',
              errorText: _errorText2,
            ),
            onChanged: (textt) {
              setState(() {
                _errorText2 = null;
              });
            },
            obscureText: true,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                              //email: _email.text, password: _pass.text
                              email: "barry.allen1@example.com",
                              password: "SuperSecretPassword!");
                      if (mounted) {
                        //----should be on register----
                        // await DatabaseHelper().checkDatabase();
                        // await DatabaseHelper().checkUserData();
                        // //-----------------------------
                        //after checking, query sqflite data
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        if (_email.text == '') {
                          _errorText = 'Please enter an email.';
                        } else {
                          _errorText = 'No user found for that email.';
                        }
                      } else if (e.code == 'wrong-password') {
                        if (_email.text == '') {
                          _errorText2 = 'Please enter a password.';
                        } else {
                          _errorText2 =
                              'Wrong password provided for that email.';
                        }
                      }
                      setState(() {});
                    }

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MainPage()),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ForgotPasswordPage(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
              //MaterialPageRoute(builder: (context) => const SecondRoute()),
            },
          ),
        ],
      ),
    );
    //LOG IN with google
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
    //don't have an account? sign up
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RegisterPage(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
              //MaterialPageRoute(builder: (context) => const SecondRoute()),
            },
          ),
        ],
      ),
    );
    //skip to main page -- to show games list
    Widget skipButton = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const MainPage(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
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
                  width: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 300
                      : 700,
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
