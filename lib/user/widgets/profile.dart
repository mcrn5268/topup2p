import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/cons-widgets/appbarwidgets/messagebutton.dart';
import 'package:topup2p/cons-widgets/appbarwidgets/signoutbutton.dart';
import 'package:topup2p/seller/widgets/sellerregister.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/login.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

import '../../logout.dart';
import '../../cons-widgets/appbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('width ${MediaQuery.of(context).size.width}');
    return SafeArea(
      child: Scaffold(
        // appBar: AppBarWidget(
        //   false,
        //   false,
        //   GlobalValues.isLoggedIn,
        //   fromProfile: true,
        // ),
        body: ListView(children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                ),
                painter: HeaderCurvedContainer(),
              ),
              Positioned(
                top: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back_ios_outlined,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const MessageButton(fromProfile: true),
                        const SignoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "${usersInfo?['name']['first']} ${usersInfo?['name']['last']}",
                      style: TextStyle(
                        fontSize: 35.0,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    radius: 80,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage:
                          AssetImage('assets/images/person-placeholder.png'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                      "${usersInfo?['name']['first']} ${usersInfo?['name']['last']}"),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('+639 999 9999'),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("${usersInfo?['email']}"),
                ),
                const Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
            child: Row(
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
                          text: 'Want to sell?',
                          style: TextStyle(
                            decoration: TextDecoration.underline
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                   Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SellerRegisterPage(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueGrey, Colors.grey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 300.0, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
