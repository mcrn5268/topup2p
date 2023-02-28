import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future selectImageFile() async {
  try {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    return result.files.first;
  } catch (e) {
    print('error $e');
  }
}

Future uploadImageFile(PlatformFile pickedFile, String uid) async {
  UploadTask? uploadTask;
  final path = 'assets/images/$uid/${pickedFile.name}';
  final file = File(pickedFile.path!);

  final ref = FirebaseStorage.instance.ref().child(path);
  uploadTask = ref.putFile(file);

  final snapshot = await uploadTask.whenComplete(() {});
  String urlDownload = await ref.getDownloadURL();

  print('Download Link: $urlDownload');
  return urlDownload;
}

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
