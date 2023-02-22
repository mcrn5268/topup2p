import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:topup2p/cloud/download-image.dart';
import 'package:topup2p/cloud/firebase-storage-delete';
import 'package:topup2p/cloud/update-to-seller.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:topup2p/seller/seller-main.dart';
import 'package:topup2p/seller/widgets/seller-profile/seller-profile.dart';
import 'package:topup2p/sqflite/sqflite-global.dart';
import 'package:topup2p/sqflite/sqfliite.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _Sname =
      TextEditingController(text: sellerData['sname']);
  final TextEditingController _email =
      TextEditingController(text: sellerData['email']);
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

  Future<void> updateSqfliteRow(String argument, var value) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        argument,
        [value, user!.uid],
      );
    });
  }

  Future updateSeller({bool? image, String? sname, String? email}) async {
    final db = await DatabaseHelper().database;
    final DocumentReference<Map<String, dynamic>> documentReference =
        dbInstance.collection('sellers').doc(sellerData['sname']);

    await dbInstance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);

      if (snapshot.exists) {
        //for shop email
        if (email != null) {
          print('for email');
          transaction.update(documentReference, {
            'email': email,
          });
          await updateSqfliteRow(
              'UPDATE seller SET email = ? WHERE sellerID = ?', email);
        }
        //for shop name
        if (sname != null) {
          print('for name');
          final DocumentReference oldDocRef =
              dbInstance.collection('sellers').doc(sellerData['sname']);
          //delete sellers old document, create a new one
          final DocumentSnapshot oldDocSnapshot = await oldDocRef.get();
          final Map<String, dynamic> oldDocData =
              oldDocSnapshot.data() as Map<String, dynamic>;

          final DocumentReference newDocRef =
              dbInstance.collection('sellers').doc(sname);

          await newDocRef.set(oldDocData);
          await oldDocRef.delete();

          final collectionReference =
              FirebaseFirestore.instance.collection('seller_games_data');

// Get all documents in the collection
          collectionReference.get().then((querySnapshot) {
            querySnapshot.docs.forEach((documentSnapshot) {
              // Get the current field value before deleting it
              dynamic fieldValue;
              if (documentSnapshot.exists) {
                fieldValue = documentSnapshot.data()['${sellerData["sname"]}'];
              }

              // Delete the old field and create a new one with the same value
              documentSnapshot.reference.update({
                '${sellerData["sname"]}': FieldValue.delete(),
              }).then((value) {
                documentSnapshot.reference.set({
                  '$sname': fieldValue,
                }, SetOptions(merge: true)).then((value) {
                  print(
                      'Field update complete for document ${documentSnapshot.id}');
                }).catchError((error) {
                  print(
                      'Error updating field for document ${documentSnapshot.id}: $error');
                });
              }).catchError((error) {
                print(
                    'Error deleting old field for document ${documentSnapshot.id}: $error');
              });
            });
          }).catchError((error) {
            print('Error getting documents: $error');
          });

          await updateSqfliteRow(
              'UPDATE seller SET sname = ? WHERE sellerID = ?', sname);
        }
        //for image
        if (image == true) {
          print('for image');
          await deleteFolderContents('assets/images/${user!.uid}');
          final path = 'assets/images/${user!.uid}/${pickedFile!.name}';
          final file = File(pickedFile!.path!);

          final ref = dbStorageInstace.ref().child(path);
          uploadTask = ref.putFile(file);

          final snapshop = await uploadTask!.whenComplete(() {});

          urlDownload = await ref.getDownloadURL();
          String assetspath = await ImagetoAssets(urlDownload!);

          print('Download Link: $urlDownload');
          transaction.update(documentReference, {
            'image': assetspath,
          });
          await updateSqfliteRow(
              'UPDATE seller SET image = ? WHERE sellerID = ?', assetspath);
        }
      }
    });

    await getSellerSqfliteData();
  }

  Future<void> _textValidator(String value) async {
    late bool flag;
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Shop name is required';
      });
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      _Sname.dispose();
      super.dispose();
    }

    bool _flag = MediaQuery.of(context).orientation == Orientation.portrait;
    Widget editProfileSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Form(
        //autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _Sname,
              decoration: InputDecoration(hintText: 'Shop name'),
              validator: (value) {
                _textValidator(value!);
                return _errorMessage;
              },
              onChanged: (value) => setState(() {
                _errorMessage = null;
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    //FOR FUTURE UPDATE, UPDATE LOCAL FIRST THEN FIRESTORE
                    userType = 'seller';
                    // form is valid
                    if (pickedFile != null ||
                        _Sname.text != sellerData['sname'] ||
                        _email.text != sellerData['email']) {
                      setState(() {
                        _isLoading = true;
                      });
                      if (_Sname.text != sellerData['sname']) {
                        await _textValidator(_Sname.text);
                      }
                      if (_errorMessage == null) {
                        await updateSeller(
                          image: pickedFile != null,
                          sname: _Sname.text != sellerData['sname']
                              ? _Sname.text
                              : null,
                          email: _email.text != sellerData['email']
                              ? _email.text
                              : null,
                        );
                        Navigator.pop(context);

                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Profile Updated')));
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SellerMain(index: 2)),
                        );
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
                                height: _flag ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2,
                                width:
                                    _flag ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 2,
                                child: ClipPath(
                                    clipper: const ShapeBorderClipper(
                                        shape: CircleBorder()),
                                    clipBehavior: Clip.hardEdge,
                                    child: (pickedFile != null)
                                        ? Image.file(
                                            File(pickedFile!.path!),
                                            fit: BoxFit.cover,
                                          )
                                        : SellerProfile().getImage()),
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
                          onTap: () {
                            selectFile();
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
