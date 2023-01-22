import 'package:flutter/material.dart';
import 'package:topup2p/widgets/customdivider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget registerSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                  ),
                ),
              ),
            ],
          ),
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
                    //sign up
                  },
                  style: ElevatedButton.styleFrom(
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
                  width: MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 700,
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
