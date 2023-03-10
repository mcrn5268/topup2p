import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/forgot_password.dart';
import 'package:topup2p/screens/register.dart';
import 'package:topup2p/widgets/custom_divider.dart';
import 'package:topup2p/widgets/google_signin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _pass = TextEditingController();
  String? _errorText;
  String? _errorText2;
  bool _isLoading = false;

//temporary
  @override
  void initState() {
    super.initState();
    _email.text = 'johnsmith@johnsmith.com';
    _pass.text = 'johnsmith6969';
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget loginSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Divider(),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _errorText,
            ),
            onChanged: (textt) {
              //if there was an error and the user changed the text
              //remove the errortext
              setState(() {
                _errorText = null;
              });
            },
          ),
          TextFormField(
            controller: _pass,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _errorText2,
            ),
            onChanged: (textt) {
              //if there was an error and the user changed the text
              //remove the errortext
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
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            //Firebase sign in
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                                    email: _email.text, password: _pass.text);
                            if (mounted) {
                              //sign in success
                              final userInfo = userCredential.user;
                              Provider.of<UserProvider>(context, listen: false)
                                  .signIn(userInfo);
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
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
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
              text: const TextSpan(
                style: TextStyle(fontSize: 15),
                children: [
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
                  pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
          ),
        ],
      ),
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
              text: const TextSpan(
                style: TextStyle(fontSize: 15),
                text: "Don't have an account?",
                children: [
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
                  pageBuilder: (_, __, ___) => const RegisterScreen(),
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
    Widget skipButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.transparent),
          ),
          onPressed: () {
            //todo
            // Navigator.pushReplacement(
            //   context,
            //   PageRouteBuilder(
            //     pageBuilder: (_, __, ___) => const MainPage(),
            //     transitionsBuilder: (_, a, __, c) =>
            //         FadeTransition(opacity: a, child: c),
            //   ),
            // );
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
                const SignIn_Google(),
                signupSection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
