import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _email = '';
  String _errorMessage = '';
  bool _isLoading = false;
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    final _auth = FirebaseAuth.instance;
    final navigator = Navigator.of(context);
    final scaffoldMsgr = ScaffoldMessenger.of(context);
    try {
      // Check if the email address is registered with your Firebase project
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        // The email address is not registered
        setState(() {
          _errorMessage = 'No user found with this email address';
          _isLoading = false;
        });
        return;
      }

      // The email address is registered, send the password reset email
      await _auth.sendPasswordResetEmail(email: email);
      scaffoldMsgr
          .showSnackBar(const SnackBar(content: Text('Check your email')));
      setState(() {
        _errorMessage = '';
        _isLoading = false;
      });

      navigator.pop();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        _errorMessage = 'An error occurred, please try again later';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.arrow_back_ios_outlined),
                          Text(
                            'Back',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 300
                      : 700,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: Column(
                    children: [
                      const Divider(),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            CircularProgressIndicator(),
                                          ],
                                        )
                                      : ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            if (_formKey.currentState!
                                                .validate()) {
                                              String email =
                                                  _emailController.text.trim();
                                              _resetPassword(email);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.black),
                                            shape: const StadiumBorder(),
                                            padding: const EdgeInsets.all(15),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const <Widget>[
                                              Text(
                                                'Reset Password',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),

                            // ElevatedButton(
                            //   onPressed: () {
                            //     if (_formKey.currentState!.validate()) {
                            //       String email = _emailController.text.trim();
                            //       _resetPassword(email);
                            //     }
                            //   },
                            //   child: const Text('Reset Password'),
                            // ),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
