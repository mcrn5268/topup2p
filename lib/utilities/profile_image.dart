import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/user_provider.dart';

Widget getImage(context) {
  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  if (userProvider.user!.image == 'assets/images/person-placeholder.png' ||
      userProvider.user!.image == 'assets/images/store-placeholder.png') {
    return CircleAvatar(
        radius: 70, backgroundImage: AssetImage(userProvider.user!.image));
  } else {
    return CircleAvatar(
      radius: 70,
      backgroundImage: FileImage(File(userProvider.user!.image)),
    );
  }
}
