class UserModel {
  final String uid;
  final String email;
  String name;
  //final String phoneNumber;
  final String type;
  String image;
  String image_url;

  UserModel(
      {required this.uid,
      required this.email,
      required this.name,
      //required this.phoneNumber,
      required this.type,
      required this.image,
      required this.image_url});
}
