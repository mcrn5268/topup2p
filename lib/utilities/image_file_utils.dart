import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

//select an image file to be used as display photo
Future selectImageFile() async {
  try {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    return result.files.first;
  } catch (e) {
    if (kDebugMode) {
      print('error $e');
    }
  }
}

//upload image file to firestore storage
Future uploadImageFile(PlatformFile pickedFile, String uid) async {
  UploadTask? uploadTask;
  final path = 'assets/images/$uid/${pickedFile.name}';
  final file = File(pickedFile.path!);

  final ref = FirebaseStorage.instance.ref().child(path);
  uploadTask = ref.putFile(file);

  // ignore: unused_local_variable
  final snapshot = await uploadTask.whenComplete(() {});
  String urlDownload = await ref.getDownloadURL();

  if (kDebugMode) {
    print('Download Link: $urlDownload');
  }
  return urlDownload;
}

//for games that has specific type of digital goods
String gameIcon(String name) {
  late String path;
  if (name == 'Mobile Legends') {
    path = 'assets/icons/diamond.png';
  } else if (name == 'Valorant') {
    path = 'assets/icons/valorant.png';
  } else {
    path = 'assets/icons/coin.png';
  }
  return path;
}
