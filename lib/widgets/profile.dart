import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/widgets/login.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

import '../logout.dart';
import 'cons-widgets/appbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(false, false, GlobalValues.isLoggedIn, fromProfile: true,),
      body: Center(
        child: InkWell(
          //temporary login page - signout
          //onTap: () => Logout().signOut(context),
          child: Image.asset(
            'assets/images/person-placeholder.png',
            width: 180,
          ),
        )
      ),
    );
  }
}