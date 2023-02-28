import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/user_model.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/user/user_main.dart';
import 'package:topup2p/widgets/custom_divider.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    _Fname.text = 'John';
    _Lname.text = 'Smith';
    _email.text = 'johnsmith2@johnsmith.com';
    _pass.text = 'johnsmith6969';
    _Cpass.text = 'johnsmith6969';
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _isLoading = false;

  void _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    final firebaseAuth = FirebaseAuth.instance;

    try {
      // Create a new user account using Firebase Authentication
      final authResult = await firebaseAuth.createUserWithEmailAndPassword(
          email: _email.text, password: _pass.text);

      // Create a new user document in Firestore
      final userData = {
        'name': '${_Fname.text} ${_Lname.text}',
        'email': _email.text,
        //'phone_number': _phoneNumberController.text,
        'type': 'normal',
        //todo
        'image': 'assets/images/person-placeholder.png'
      };
      FirestoreService().create('users', '${authResult.user!.uid}', userData);

      // Update the user data in the UserProvider
      final user = UserModel(
          uid: authResult.user!.uid,
          email: _email.text,
          name: '${_Fname.text} ${_Lname.text}',
          //phoneNumber: _phoneNumberController.text,
          type: 'normal',
          //todo image
          image: 'assets/images/person-placeholder.png');
      Provider.of<UserProvider>(context, listen: false).setUser(user);
    } catch (e) {
      // Display an error message
      print('Error registering user: $e');
    } finally {
      Navigator.pop(context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _Fname.dispose();
    _Lname.dispose();
    _email.dispose();
    _pass.dispose();
    _Cpass.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (_form.currentState!.validate()) {
                              _registerUser();
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
      body: ListView(
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
