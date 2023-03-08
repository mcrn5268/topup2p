// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:topup2p/utilities/profile_image.dart';
import 'package:topup2p/widgets/loading_screen.dart';
import '../../../../cloud/download-image.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({this.favorites, super.key});
  final List<Item>? favorites;

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
  FavoritesProvider? favProvider;

  Future<void> _textValidator(String value) async {
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Shop name is required';
      });
    }
  }

  @override
  void dispose() {
    _Sname.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.favorites != null) {
      favProvider = Provider.of<FavoritesProvider>(context, listen: false);
      favProvider!.addItems(widget.favorites!, notify: false);
    }
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _Sname.text = userProvider.user!.name;
  }

  @override
  Widget build(BuildContext context) {
    bool flag = MediaQuery.of(context).orientation == Orientation.portrait;
    Widget editProfileSection = Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            //todo maybe let the user type normal edit name
            Visibility(
              visible: userProvider.user!.type == 'seller',
              child: TextFormField(
                controller: _Sname,
                decoration: const InputDecoration(hintText: 'Shop name'),
                validator: (value) {
                  if (userProvider.user!.type == 'seller') {
                    _textValidator(value!);
                    return _errorMessage;
                  }
                  return null;
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
                          Map<String, dynamic> imageMap = {'image': assetsPath};
                          if (urlDownload != null) {
                            imageMap['image'] = await ImagetoAssets(
                                url: urlDownload!, uid: userProvider.user!.uid);
                            imageMap['image_url'] = urlDownload;
                          }
                          FirestoreService().create(
                              collection: 'users',
                              documentId: userProvider.user!.uid,
                              data: imageMap);
                          print(
                              'edit profile screen ${Provider.of<FavoritesProvider>(context, listen: false).favorites.length}');
                          userProvider.updateUser(image: imageMap['image']);
                          //if user is seller
                          if (userProvider.user!.type == 'seller') {
                            Map<String, dynamic> sellerData =
                                await FirestoreService().read(
                                    collection: 'sellers',
                                    documentId: userProvider.user!.uid);
                            sellerData['games'].forEach((key, value) {
                              FirestoreService().create(
                                  collection: 'users',
                                  documentId: userProvider.user!.name,
                                  data: {
                                    'info': {'image': urlDownload}
                                  },
                                  subcollection: 'games',
                                  subdocumentId: key);
                              FirestoreService().create(
                                  collection: 'seller_games_data',
                                  documentId: key,
                                  data: {
                                    userProvider.user!.name: {
                                      'info': {'image': urlDownload}
                                    }
                                  });
                            });
                          }
                          //update messages - image
                          final forMessages = await FirestoreService().read(
                              collection: 'messages',
                              documentId: 'users_conversations',
                              subcollection: userProvider.user!.uid);
                          if (forMessages != null) {
                            List<dynamic> documents = forMessages.docs;
                            for (var document in documents) {
                              FirestoreService().create(
                                  collection: 'messages',
                                  documentId: 'users',
                                  data: {
                                    'other_user': {'image': urlDownload}
                                  },
                                  subcollection: document.id,
                                  subdocumentId:
                                      document.data()!["conversationId"]);
                            }
                          }
                        }

                        //name is changed
                        if (_Sname.text != userProvider.user!.name) {
                          //purpose is because the processing of firestore is async and won't be using await
                          //ifi not stored then userProvider.user!.name will be updated before being used by FirestoreService
                          String oldName = userProvider.user!.name;
                          //update seller_games_data and seller - games subcollection
                          if (userProvider.user!.type == 'seller') {
                            Map<String, dynamic> sellerData =
                                await FirestoreService().read(
                                    collection: 'sellers',
                                    documentId: userProvider.user!.uid);
                            sellerData['games'].forEach((key, value) async {
                              //seller_games_data

                              //read seller_games_data old data
                              Map<String, dynamic> oldFieldSGD =
                                  await FirestoreService().read(
                                      collection: 'seller_games_data',
                                      documentId: key);
                              Map<String, dynamic> newField =
                                  oldFieldSGD[oldName];
                              newField['info']['name'] = _Sname.text;
                              //write seller_games_data new data
                              FirestoreService().create(
                                  collection: 'seller_games_data',
                                  documentId: key,
                                  data: {_Sname.text: newField});

                              //delete seller_games_data old data
                              FirestoreService().deleteField(
                                  collection: 'seller_games_data',
                                  documentId: key,
                                  field: oldName);

                              //update users - subcollection
                              FirestoreService().create(
                                  collection: 'sellers',
                                  documentId: userProvider.user!.uid,
                                  data: {
                                    'info': {'name': _Sname.text}
                                  },
                                  subcollection: 'games',
                                  subdocumentId: key);
                            });
                            userProvider.updateUser(name: _Sname.text);
                          }

                          //update users collection
                          FirestoreService().create(
                              collection: 'users',
                              documentId: userProvider.user!.uid,
                              data: {'name': _Sname.text});
                          //update sellers collection
                          FirestoreService().create(
                              collection: 'sellers',
                              documentId: userProvider.user!.uid,
                              data: {'name': _Sname.text});

                          //update messages - name
                          final forMessages = await FirestoreService().read(
                              collection: 'messages',
                              documentId: 'users_conversations',
                              subcollection: userProvider.user!.uid);
                          if (forMessages != null) {
                            List<dynamic> documents = forMessages.docs;
                            for (var document in documents) {
                              FirestoreService().create(
                                  collection: 'messages',
                                  documentId: 'users',
                                  data: {
                                    'other_user': {'name': _Sname.text}
                                  },
                                  subcollection: document.id,
                                  subdocumentId:
                                      document.data()!["conversationId"]);
                            }
                          }
                        }
                        if (widget.favorites != null) {
                          Navigator.pop(context, favProvider!.favorites);
                        } else {
                          Navigator.pop(context);
                        }

                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile Updated')));
                      } else {
                        setState(() {
                          _isLoading = false;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Shop name is already taken. Try again.')));
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('No changes has been made')));
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
    Widget editProfileBody = ListView(
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
                      //display photo
                      SizedBox(
                        height: flag
                            ? MediaQuery.of(context).size.width
                            : MediaQuery.of(context).size.width / 2,
                        width: flag
                            ? MediaQuery.of(context).size.height
                            : MediaQuery.of(context).size.height / 2,
                        child: ClipPath(
                            clipper:
                                const ShapeBorderClipper(shape: CircleBorder()),
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
                        right: flag ? 0 : 85,
                        bottom: flag ? 20 : 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            shape: BoxShape.circle,
                          ),
                          height: flag
                              ? MediaQuery.of(context).size.width / 7
                              : MediaQuery.of(context).size.width / 9,
                          width: flag
                              ? MediaQuery.of(context).size.height / 7
                              : MediaQuery.of(context).size.height / 9,
                          child: const ClipPath(
                              clipper: ShapeBorderClipper(
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
                          right: flag ? 20 : 100,
                          top: flag ? 20 : 0,
                          child: InkWell(
                            child: const ClipPath(
                                clipper: ShapeBorderClipper(
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
    );
    return Scaffold(
        body: _isLoading
            ? const Center(
                child: LoadingScreen(),
              )
            : editProfileBody);
  }
}
