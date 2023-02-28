import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:topup2p/utilities/profile_image.dart';
import 'package:topup2p/widgets/loading_screen.dart';
import '../../../../cloud/download-image.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _Sname = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? urlDownload;
  late UserProvider userProvider;

  Future<void> _textValidator(String value) async {
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Shop name is required';
      });
    } else {
      final document = await FirestoreService().read('sellers', value);
      bool flag = document == null ? false : true;
      setState(() {
        _errorMessage = flag ? 'Shop name is already taken' : null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _Sname.dispose();
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _Sname.text = userProvider.user!.name;
  }

  @override
  Widget build(BuildContext context) {
    bool _flag = MediaQuery.of(context).orientation == Orientation.portrait;
    Widget editProfileSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Form(
        //autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          children: [
            Visibility(
              visible: userProvider.user!.type == 'seller',
              child: TextFormField(
                controller: _Sname,
                decoration: InputDecoration(hintText: 'Shop name'),
                validator: (value) {
                  if (userProvider.user!.type == 'seller') {
                    _textValidator(value!);
                    return _errorMessage;
                  }
                },
                onChanged: (value) => setState(() {
                  _errorMessage = null;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // form is valid
                    if (pickedFile != null ||
                        _Sname.text != userProvider.user!.name) {
                      setState(() {
                        _isLoading = true;
                      });
                      if (_Sname.text != userProvider.user!.name) {
                        await _textValidator(_Sname.text);
                      }
                      if (_errorMessage == null) {
                        //image is changed
                        if (pickedFile != null) {
                          urlDownload = await uploadImageFile(
                              pickedFile!, userProvider.user!.uid);
                          String assetsPath =
                              userProvider.user!.type == 'seller'
                                  ? 'assets/images/store-placeholder.png'
                                  : 'assets/images/person-placeholder.png';
                          if (urlDownload != null) {
                            assetsPath = await ImagetoAssets(
                                urlDownload!, userProvider.user!.uid);
                          }
                          FirestoreService().create('users',
                              userProvider.user!.uid, {'image': assetsPath});
                          userProvider.updateUser(image: assetsPath);
                          Map<String, dynamic> sellerData =
                              await FirestoreService()
                                  .read('sellers', userProvider.user!.name);
                          sellerData['games'].forEach((key, value) {
                            FirestoreService().create(
                                'seller_games_data_2',
                                userProvider.user!.name,
                                {
                                  'info': {'image': urlDownload}
                                },
                                subcollection: key,
                                subdocumentId: key);
                            FirestoreService()
                                .create('seller_games_data', key, {
                              userProvider.user!.name: {
                                'info': {'image': urlDownload}
                              }
                            });
                          });
                        }

                        //name is changed
                        if (_Sname.text != userProvider.user!.name) {
                          FirestoreService().create('users',
                              userProvider.user!.uid, {'name': _Sname.text});
                          FirestoreService().replaceDocumentnCollection(
                              userProvider.user!.name, _Sname.text);
                          userProvider.updateUser(name: _Sname.text);
                        }
                        Navigator.pop(context);

                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Profile Updated')));
                      } else {
                        setState(() {
                          _isLoading = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text(
                                  'Shop name is already taken. Try again.')));
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('No changes has been made')));
                      Navigator.pop(context);
                    }
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
                      'Update',
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
                children: const <Widget>[Icon(Icons.arrow_back_ios_outlined)],
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
                                        : getImage(context)),
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
                              if (pickedFile != null) ...[
                                //remove image icon
                                Positioned(
                                  right: _flag ? 20 : 100,
                                  top: _flag ? 20 : 0,
                                  child: InkWell(
                                    child: ClipPath(
                                        clipper: const ShapeBorderClipper(
                                            shape: CircleBorder()),
                                        clipBehavior: Clip.hardEdge,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.black,
                                        )),
                                    onTap: () => setState(() {
                                      pickedFile = null;
                                    }),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          onTap: () async {
                            pickedFile = await selectImageFile();

                            setState(() {});
                          },
                        ),
                      ),
                      editProfileSection,
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
