import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/download-image.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/main.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'dart:io';

import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/loading_screen.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _Sname = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  PlatformFile? pickedFile;
  String? urlDownload;

  void _textValidator(String value) async {
    late bool flag;
    if (value.isEmpty) {
      _errorMessage = 'Shop name is required';
    }
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(value)
        .get()
        .then((document) {
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
  void dispose() {
    _Sname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
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
                    // form is valid
                    setState(() {
                      _isLoading = true;
                    });
                    //picked a file
                    if (pickedFile != null) {
                      urlDownload = await uploadImageFile(
                          pickedFile!, userProvider.user!.uid);
                    }
                    String assetsPath = 'assets/images/store-placeholder.png';
                    if (urlDownload != null) {
                      assetsPath = await ImagetoAssets(
                          urlDownload!, userProvider.user!.uid);
                    }
                    final updateData = <String, dynamic>{
                      "name": _Sname.text,
                      "type": "seller",
                      "image": assetsPath
                    };
                    //update users info to sellers info (ex: name to shop name)
                    await FirestoreService()
                        .update('users', userProvider.user!.uid, updateData);
                    await FirestoreService()
                        .delete('user_games_data', userProvider.user!.uid);
                    Provider.of<FavoritesProvider>(context, listen: false).clearFavorites();
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const Topup2p(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                    userProvider.updateUser(name:_Sname.text ,type:'seller' ,image:assetsPath);
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
                                height: _flag
                                    ? MediaQuery.of(context).size.width
                                    : MediaQuery.of(context).size.width / 2,
                                width: _flag
                                    ? MediaQuery.of(context).size.height
                                    : MediaQuery.of(context).size.height / 2,
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
                                      ? MediaQuery.of(context).size.width / 7
                                      : MediaQuery.of(context).size.width / 9,
                                  width: _flag
                                      ? MediaQuery.of(context).size.height / 7
                                      : MediaQuery.of(context).size.height / 9,
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
                            setState(() {
                              pickedFile = selectImageFile() as PlatformFile?;
                            });
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
