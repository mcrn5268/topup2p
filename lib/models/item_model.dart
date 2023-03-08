// ignore_for_file: non_constant_identifier_names

class Item {
  final String name;
  final String image;
  final String image_banner;

  Item({required this.name, required this.image, required this.image_banner});

  Map<String, dynamic> toMap() {
    return {'name': name, 'image': image, 'image_banner': image_banner};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          image == other.image &&
          image_banner == other.image_banner;

  @override
  int get hashCode => identityHashCode(this);

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      image: map['image'],
      image_banner: map['image_banner'],
    );
  }
}
