import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/cons-widgets/appbarwidgets/signoutbutton.dart';
import 'package:topup2p/seller/widgets/seller-profile/edit-profile.dart';
import 'package:topup2p/seller/widgets/seller-profile/update-card-db.dart';
import 'package:topup2p/seller/widgets/sellerregister.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/widgets/wallets.dart';
import 'package:topup2p/user/widgets/login.dart';
import 'package:topup2p/global/globals.dart';

class SellerProfile extends StatelessWidget {
  const SellerProfile({super.key});
  Widget getImage() {
    if (sellerData['image'] == 'assets/images/store-placeholder.png') {
      return CircleAvatar(
          radius: 70, backgroundImage: AssetImage('${sellerData['image']}'));
    } else {
      return CircleAvatar(
        radius: 70,
        backgroundImage: FileImage(File('${sellerData['image']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool flag = sellerData['image'] == 'assets/images/store-placeholder.png';
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   flexibleSpace: Padding(
        //     padding: const EdgeInsets.only(right: 8.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         const SignoutButton(),
        //       ],
        //     ),
        //   ),
        // ),
        body: ListView(children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                ),
                painter: HeaderCurvedContainer(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SignoutButton(),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                    child: Text(
                      "${sellerData['sname']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35.0,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        //fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CircleAvatar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      radius: 80,
                      child: getImage()),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.edit, color: Colors.grey),
                      Text('Ediit Profile')
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const EditProfile(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.store),
                  title: Text("${sellerData['sname']}"),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('+639 999 9999'),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("${sellerData['email']}"),
                ),
                const Divider(),
                InkWell(
                  child: ListTile(
                    leading: Icon(Icons.wallet),
                    title: const Text("Wallets"),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SellerWallets(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    ).then((_) => updateSellerFirestore())
                ),
                const Divider(),
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
