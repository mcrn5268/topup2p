import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/sqflite/sqfliite.dart';
import 'package:topup2p/cons-widgets/customdivider.dart';
import 'package:topup2p/cloud/writeDB.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _Fname = TextEditingController();

  final TextEditingController _Lname = TextEditingController();

  final TextEditingController _email = TextEditingController();

  final TextEditingController _pass = TextEditingController();

  final TextEditingController _Cpass = TextEditingController();
  bool _obscureText = true;
  late FocusNode focusNode;
  bool _hasInputError = false;
  String text = '';

  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          //CHECK AGAIN FOR VALID EMAIL ADDRESS NOT ONLY .COM
          if (text.contains('@') && text.endsWith('.com')) {
            _hasInputError = false;
          } else {
            _hasInputError = true;
          }
        });
      }
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      _Fname.dispose();
      _Lname.dispose();
      _email.dispose();
      _pass.dispose();
      _Cpass.dispose();
      super.dispose();
    }
    Widget registerSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Form(
        //autovalidateMode: AutovalidateMode.always,
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: _Fname,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: _Lname,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              focusNode: focusNode,
              controller: _email,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'Email',
                errorText:
                    _hasInputError ? "Enter a Valid Email Address" : null,
              ),
              onChanged: (textt) {
                text = textt;
              },
            ),
            TextFormField(
              controller: _pass,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: InkWell(
                  onTap: _toggle,
                  child: Icon(
                    _obscureText
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 15.0,
                    color: Colors.black,
                  ),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a password";
                } else if (value.length < 8) {
                  return "Password must be atleast 8 characters long";
                } else {
                  return null;
                }
              },
              obscureText: _obscureText,
            ),
            TextFormField(
              controller: _Cpass,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please re-enter the password";
                } else if (value != _pass.text) {
                  return "Password do not match";
                } else {
                  return null;
                }
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
                            .createUserWithEmailAndPassword(
                                //email: _email.text, password: _pass.text
                                email: "barry.allen@example.com",
                                password: "SuperSecretPassword!");
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                          });
                          userType = 'normal';
                          //send initial data to cloud
                          await userDataFirestore(
                              userCredential, _Fname.text, _Lname.text);
                          // DatabaseHelper().checkDatabase();
                          // DatabaseHelper().checkUserData();
                          Navigator.pop(context);
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          print('The account already exists for that email.');
                        }
                      } catch (e) {
                        print(e);
                      }
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
                          'Sign up',
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
      ),
    );
    //SIGN UP with google
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
    //back to log in page
    Widget backButton = Column(
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
      ],
    );
    return Scaffold(
      body: _isLoading
          ? Center(
              child: const LoadingScreen(),
            )
          : ListView(
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      backButton,
                      Image.asset(
                        'assets/images/logo.png',
                        width: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? 300
                            : 700,
                      ),
                      registerSection,
                      const CustomDivider(),
                      loginWith,
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
