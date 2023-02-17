import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:topup2p/cloud/update-to-seller.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:topup2p/seller/seller-main.dart';

class SellerRegisterPage extends StatefulWidget {
  const SellerRegisterPage({super.key});

  @override
  State<SellerRegisterPage> createState() => _SellerRegisterPageState();
}

class _SellerRegisterPageState extends State<SellerRegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _Sname = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? urlDownload;
  Future selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      pickedFile = result.files.first;
      setState(() {});
    } catch (e) {
      print('error $e');
    }
  }

  Future uploadFile() async {
    final path = 'assets/images/${user!.uid}/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = dbStorageInstace.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshop = await uploadTask!.whenComplete(() {});

    urlDownload = await ref.getDownloadURL();
    print('Download Link: $urlDownload');
  }

  void _textValidator(String value) async {
    late bool flag;
    if (value.isEmpty) {
      _errorMessage = 'Shop name is required';
    }
    await dbInstance.collection('sellers').doc(value).get().then((document) {
      if (!document.exists) {
        flag = false;
      } else {
        flag = true;
      }
    });
    setState(() {
      _errorMessage = flag ? 'Shop name is already taken' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      _Sname.dispose();
      super.dispose();
    }

    bool _flag = MediaQuery.of(context).orientation == Orientation.portrait;
    Widget registerSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Form(
        //autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _Sname,
              decoration: InputDecoration(hintText: 'Shop Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Shop name is required';
                }
                _textValidator(value);
                return _errorMessage;
              },
              onChanged: _errorMessage = null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    userType = 'seller';
                    setState(() {
                      _isLoading = true;
                    });
                    // form is valid
                    if (pickedFile != null) {
                      await uploadFile();
                    }
                    await ToSeller(_Sname.text, urlDownload);

                    Navigator.pop(context);
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SellerMain(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
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
                      'Proceed',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      body: _isLoading
          ? Center(
              child: const LoadingScreen(),
            )
          : ListView(
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      backButton,
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: InkWell(
                          child: Stack(
                            children: [
                              Container(
                                height: _flag ? logicalWidth : logicalWidth / 2,
                                width:
                                    _flag ? logicalHeight : logicalHeight / 2,
                                child: ClipPath(
                                  clipper: const ShapeBorderClipper(
                                      shape: CircleBorder()),
                                  clipBehavior: Clip.hardEdge,
                                  child: (pickedFile != null)
                                      ? Image.file(
                                          File(pickedFile!.path!),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/upload-image.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              //upload icon
                              Positioned(
                                right: _flag ? 0 : 85,
                                bottom: _flag ? 20 : 0,
                                child: Container(
                                  decoration: new BoxDecoration(
                                    color: Colors.blueGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  height: _flag
                                      ? logicalWidth / 7
                                      : logicalWidth / 9,
                                  width: _flag
                                      ? logicalHeight / 7
                                      : logicalHeight / 9,
                                  child: ClipPath(
                                      clipper: const ShapeBorderClipper(
                                          shape: CircleBorder()),
                                      clipBehavior: Clip.hardEdge,
                                      child: Icon(
                                        Icons.upload,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            selectFile();
                          },
                        ),
                      ),
                      registerSection,
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
