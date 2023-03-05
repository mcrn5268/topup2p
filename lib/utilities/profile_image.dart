import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/download-image.dart';
import 'package:topup2p/providers/user_provider.dart';

Widget getImage(context) {
  UserProvider userProvider = Provider.of<UserProvider>(context);
  print('userProvider.user!.image ${userProvider.user!.image}');
  if (userProvider.user!.image == 'assets/images/person-placeholder.png' ||
      userProvider.user!.image == 'assets/images/store-placeholder.png') {
    return CircleAvatar(
        radius: 70, backgroundImage: AssetImage(userProvider.user!.image));
  } else {
    final file = File(userProvider.user!.image);
    //if file doesn't exist in local files
    if (!file.existsSync()) {
      //image url to assets
      ImagetoAssets(
              url: userProvider.user!.image_url, uid: userProvider.user!.uid)
          .then((path) {
        userProvider.updateUser(image: path);
      });
      //temporary container while waiting for userprovider notifylistener
      return Container();
    } else {
      return CircleAvatar(
        radius: 70,
        backgroundImage: FileImage(File(userProvider.user!.image)),
      );
    }
  }
}
