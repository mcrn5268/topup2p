// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

//DOWNLOAD IMAGE FROM DOWNLOAD URL GIVEN FROM FIRESTORE STORAGE THEN STORE LOCALLY

Future<String> imageToAssets({required String url, required String uid}) async {
  final response = await http.get(Uri.parse(url));
  final documentDirectory = await getApplicationDocumentsDirectory();
  final filePath = '${documentDirectory.path}/assets/images/$uid';
  String folderPath = await createFolderIfNotExist(filePath);

  Uri uri = Uri.parse(url);
  String fileName = uri.pathSegments.last;

  final filePath3 = '${documentDirectory.path}/$fileName';

  final file = File(filePath3);
  await file.writeAsBytes(response.bodyBytes);
  return filePath3;
}

Future<String> createFolderIfNotExist(String folderPath) async {
  final directory = Directory(folderPath);
  if (await directory.exists()) {
    return directory.path;
  } else {
    await directory.create(recursive: true);
    return directory.path;
  }
}
