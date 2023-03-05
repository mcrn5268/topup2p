import 'dart:ui';
import 'package:topup2p/models/item_model.dart';

//for size of device
var pixelRatio = window.devicePixelRatio;
var logicalScreenSize = window.physicalSize / pixelRatio;
var logicalWidth = logicalScreenSize.width;
var logicalHeight = logicalScreenSize.height;

//favorited icons
final Map<bool, String> icon = {
  true: 'assets/icons/bookmark-icon-yellow.png',
  false: 'assets/icons/bookmark-icon-white.png'
};

//items objects list
List<Item> itemsObjectList = [];

//constant items list
List<Map<String, dynamic>> productItemsMap = [
  {
    'name': 'Mobile Legends',
    'image': 'assets/gameslogos/Mobile Legends.png',
    'image_banner': 'assets/gameslogos-banner/Mobile Legends.jpeg'
  },
  {
    'name': 'Valorant',
    'image': 'assets/gameslogos/Valorant.png',
    'image_banner': 'assets/gameslogos-banner/Valorant.jpg'
  },
  {
    'name': 'Call of Duty Mobile',
    'image': 'assets/gameslogos/Call of Duty Mobile.png',
    'image_banner': 'assets/gameslogos-banner/Call of Duty Mobile.jpg'
  },
  {
    'name': 'Leauge of Legends: Wild RIft',
    'image': 'assets/gameslogos/Leauge of Legends Wild RIft.png',
    'image_banner': 'assets/gameslogos-banner/Leauge of Legends Wild RIft.png'
  },
  {
    'name': 'Free Fire MAX',
    'image': 'assets/gameslogos/Free Fire MAX.png',
    'image_banner': 'assets/gameslogos-banner/Free Fire MAX.jpg'
  },
  {
    'name': 'Garena Shells',
    'image': 'assets/gameslogos/Garena Shells.png',
    'image_banner': 'assets/gameslogos-banner/Garena Shells.jpg'
  },
  {
    'name': 'Steam Wallet Code',
    'image': 'assets/gameslogos/Steam Wallet Code.png',
    'image_banner': 'assets/gameslogos-banner/Steam Wallet Code.png'
  },
  {
    'name': 'PUBG Mobile UC Vouchers',
    'image': 'assets/gameslogos/PUBG Mobile UC Vouchers.png',
    'image_banner': 'assets/gameslogos-banner/PUBG Mobile UC Vouchers.jpg'
  },
  {
    'name': 'Counter Strike: Global Offensive',
    'image': 'assets/gameslogos/Counter Strike Global Offensive.png',
    'image_banner':
        'assets/gameslogos-banner/Counter Strike Global Offensive.jpg'
  },
  {
    'name': 'MU Origin 3',
    'image': 'assets/gameslogos/MU Origin 3.png',
    'image_banner': 'assets/gameslogos-banner/MU Origin 3.png'
  },
  {
    'name': 'Tinder Voucher Code',
    'image': 'assets/gameslogos/Tinder Voucher Code.png',
    'image_banner': 'assets/gameslogos-banner/Tinder Voucher Code.jpg'
  },
  {
    'name': 'Punishing: Gray Raven',
    'image': 'assets/gameslogos/Punishing Gray Raven.jpg',
    'image_banner': 'assets/gameslogos-banner/Punishing Gray Raven.jpg'
  },
  {
    'name': 'MU Origin 2',
    'image': 'assets/gameslogos/MU Origin 2.jpg',
    'image_banner': 'assets/gameslogos-banner/MU Origin 2.png'
  },
  {
    'name': 'LifeAfter',
    'image': 'assets/gameslogos/LifeAfter.jpg',
    'image_banner': 'assets/gameslogos-banner/LifeAfter.jpeg'
  },
  {
    'name': 'Mirage: Perfect Skyline',
    'image': 'assets/gameslogos/Mirage Perfect Skyline.jpg',
    'image_banner': 'assets/gameslogos-banner/Mirage Perfect Skyline.png'
  },
  {
    'name': 'Basketrio',
    'image': 'assets/gameslogos/Basketrio.jpg',
    'image_banner': 'assets/gameslogos-banner/Basketrio.png'
  },
  {
    'name': 'Be The King: Judge Destiny',
    'image': 'assets/gameslogos/Be The King Judge Destiny.jpg',
    'image_banner': 'assets/gameslogos-banner/Be The King Judge Destiny.jepg'
  },
  {
    'name': 'ONE PUNCH MAN: The Strongest',
    'image': 'assets/gameslogos/ONE PUNCH MAN The Strongest.png',
    'image_banner': 'assets/gameslogos-banner/ONE PUNCH MAN The Strongest.jpg'
  },
  {
    'name': 'Identity V',
    'image': 'assets/gameslogos/Identity V.jpg',
    'image_banner': 'assets/gameslogos-banner/Identity V.jpg'
  },
  {
    'name': 'ZEPETO',
    'image': 'assets/gameslogos/ZEPETO.png',
    'image_banner': 'assets/gameslogos-banner/ZEPETO.png'
  },
  {
    'name': 'Apex Legends Mobile',
    'image': 'assets/gameslogos/Apex Legends Mobile.jpg',
    'image_banner': 'assets/gameslogos-banner/Apex Legends Mobile.jpg'
  },
  {
    'name': '8 Ball Pool',
    'image': 'assets/gameslogos/8 Ball Pool.png',
    'image_banner': 'assets/gameslogos-banner/8 Ball Pool.jpg'
  },
  {
    'name': 'Legends of Runeterra',
    'image': 'assets/gameslogos/Legends of Runeterra.jpg',
    'image_banner': 'assets/gameslogos-banner/Legends of Runeterra.jpg'
  },
  {
    'name': 'Shining Nikki',
    'image': 'assets/gameslogos/Shining Nikki.jpg',
    'image_banner': 'assets/gameslogos-banner/Shining Nikki.png'
  },
  {
    'name': 'Super Sus',
    'image': 'assets/gameslogos/Super Sus.png',
    'image_banner': 'assets/gameslogos-banner/Super Sus.png'
  },
  {
    'name': 'Tamashi: Rise of Yokai',
    'image': 'assets/gameslogos/Tamashi Rise of Yokai.png',
    'image_banner': 'assets/gameslogos-banner/Tamashi Rise of Yokai.jpg'
  },
  {
    'name': 'World War Heroes',
    'image': 'assets/gameslogos/World War Heroes.png',
    'image_banner': 'assets/gameslogos-banner/World War Heroes.png'
  },
  {
    'name': 'Super Mecha Champions',
    'image': 'assets/gameslogos/Super Mecha Champions.png',
    'image_banner': 'assets/gameslogos-banner/Super Mecha Champions.png'
  },
  {
    'name': 'Grand Theft Auto V: Premium Online Edition',
    'image': 'assets/gameslogos/Grand Theft Auto V Premium Online Edition.png',
    'image_banner':
        'assets/gameslogos-banner/Grand Theft Auto V Premium Online Edition.png'
  },
  {
    'name': 'MARVEL Super War',
    'image': 'assets/gameslogos/MARVEL Super War.png',
    'image_banner': 'assets/gameslogos-banner/MARVEL Super War.png'
  },
  {
    'name': 'WWE 2k22 - Steam',
    'image': 'assets/gameslogos/WWE 2k22 - Steam.jpg',
    'image_banner': 'assets/gameslogos-banner/WWE 2k22 - Steam.jpg'
  },
  {
    'name': 'Onmyoji Arena',
    'image': 'assets/gameslogos/Onmyoji Arena.png',
    'image_banner': 'assets/gameslogos-banner/Onmyoji Arena.jpg'
  },
  {
    'name': 'Dawn Era',
    'image': 'assets/gameslogos/Dawn Era.png',
    'image_banner': 'assets/gameslogos-banner/Dawn Era.jpeg'
  },
  {
    'name': 'Sausage Man',
    'image': 'assets/gameslogos/Sausage Man.jpg',
    'image_banner': 'assets/gameslogos-banner/Sausage Man.jpg'
  },
  {
    'name': 'Hyper Front',
    'image': 'assets/gameslogos/Hyper Front.png',
    'image_banner': 'assets/gameslogos-banner/Hyper Front.png'
  },
  {
    'name': 'MARVEL Strike Force',
    'image': 'assets/gameslogos/MARVEL Strike Force.jpg',
    'image_banner': 'assets/gameslogos-banner/MARVEL Strike Force.png'
  },
  {
    'name': 'NBA 2k22 Steam',
    'image': 'assets/gameslogos/NBA 2k22 Steam.png',
    'image_banner': 'assets/gameslogos-banner/NBA 2k22 Steam.jpeg'
  },
  {
    'name': 'Red Dead Redemption 2',
    'image': 'assets/gameslogos/Red Dead Redemption 2.png',
    'image_banner': 'assets/gameslogos-banner/Red Dead Redemption 2.jpeg'
  },
  {
    'name': "Tiny Tina's Assult on Dragon Keep",
    'image': "assets/gameslogos/Tiny Tina's Assult on Dragon Keep.jpg",
    'image_banner':
        "assets/gameslogos-banner/Tiny Tina's Assult on Dragon Keep.jpeg"
  },
  {
    'name': "Tiny Tina's Wonderlands",
    'image': "assets/gameslogos/Tiny Tina's Wonderlands.jpg",
    'image_banner': "assets/gameslogos-banner/Tiny Tina's Wonderlands.png"
  },
  {
    'name': 'Dragon City',
    'image': 'assets/gameslogos/Dragon City.png',
    'image_banner': 'assets/gameslogos-banner/Dragon City.png'
  },
  {
    'name': 'EOS Red',
    'image': 'assets/gameslogos/EOS Red.png',
    'image_banner': 'assets/gameslogos-banner/EOS Red.jpg'
  },
  {
    'name': 'The Lord of the Rings: Rise to War',
    'image': 'assets/gameslogos/The Lord of the Rings Rise to War.jpg',
    'image_banner':
        'assets/gameslogos-banner/The Lord of the Rings Rise to War.jpg'
  },
  {
    'name': 'Harry Potter: Puzzle & Speels',
    'image': 'assets/gameslogos/Harry Potter Puzzle & Speels.jpg',
    'image_banner': 'assets/gameslogos-banner/Harry Potter Puzzle & Speels.jpg'
  },
  {
    'name': 'Cave Shooter',
    'image': 'assets/gameslogos/Cave Shooter.png',
    'image_banner': 'assets/gameslogos-banner/Cave Shooter.jpg'
  },
  {
    'name': 'Club Vegas',
    'image': 'assets/gameslogos/Club Vegas.png',
    'image_banner': 'assets/gameslogos-banner/Club Vegas.png'
  },
  {
    'name': 'Top Eleven',
    'image': 'assets/gameslogos/Top Eleven.png',
    'image_banner': 'assets/gameslogos-banner/Top Eleven.jpeg'
  },
  {
    'name': 'Asphalt 9: Legends',
    'image': 'assets/gameslogos/Asphalt 9 Legends.png',
    'image_banner': 'assets/gameslogos-banner/Asphalt 9 Legends.jpg'
  },
  {
    'name': 'Modern Combat 5: Blackout',
    'image': 'assets/gameslogos/Modern Combat 5 Blackout.jpg',
    'image_banner': 'assets/gameslogos-banner/Modern Combat 5 Blackout.png'
  },
  {
    'name': 'Badlanders',
    'image': 'assets/gameslogos/Badlanders.png',
    'image_banner': 'assets/gameslogos-banner/Badlanders.jpg'
  },
  {
    'name': 'Heroes Evolved',
    'image': 'assets/gameslogos/Heroes Evolved.jpg',
    'image_banner': 'assets/gameslogos-banner/Heroes Evolved.jpg'
  },
  {
    'name': 'Tom and Jerry: Chase',
    'image': 'assets/gameslogos/Tom and Jerry Chase.png',
    'image_banner': 'assets/gameslogos-banner/Tom and Jerry Chase.jpg'
  },
  {
    'name': 'MARVEL Duel',
    'image': 'assets/gameslogos/MARVEL Duel.png',
    'image_banner': 'assets/gameslogos-banner/MARVEL Duel.jpg'
  },
  {
    'name': 'Turbo VPN',
    'image': 'assets/gameslogos/Turbo VPN.png',
    'image_banner': 'assets/gameslogos-banner/Turbo VPN.png'
  },
  {
    'name': 'Omlet Arcade',
    'image': 'assets/gameslogos/Omlet Arcade.png',
    'image_banner': 'assets/gameslogos-banner/Omlet Arcade.jpg'
  },
  {
    'name': 'Bleach Mobile 3D',
    'image': 'assets/gameslogos/Bleach Mobile 3D.png',
    'image_banner': 'assets/gameslogos-banner/Bleach Mobile 3D.png'
  },
  {
    'name': 'Disorder',
    'image': 'assets/gameslogos/Disorder.png',
    'image_banner': 'assets/gameslogos-banner/Disorder.jpg'
  },
  {
    'name': 'Captain Tsubasa: Dream Team',
    'image': 'assets/gameslogos/Captain Tsubasa Dream Team.png',
    'image_banner': 'assets/gameslogos-banner/Captain Tsubasa Dream Team.png'
  },
  {
    'name': 'Cooking Adventure',
    'image': 'assets/gameslogos/Cooking Adventure.png',
    'image_banner': 'assets/gameslogos-banner/Cooking Adventure.jpg'
  },
  {
    'name': 'Jade Dynasty: New Fantasy',
    'image': 'assets/gameslogos/Jade Dynasty New Fantasy.png',
    'image_banner': 'assets/gameslogos-banner/Jade Dynasty New Fantasy.jpg'
  },
  {
    'name': 'OlliOlli World',
    'image': 'assets/gameslogos/OlliOlli World.jpg',
    'image_banner': 'assets/gameslogos-banner/OlliOlli World.jpeg'
  },
  {
    'name': 'Sprite Fantasia',
    'image': 'assets/gameslogos/Sprite Fantasia.png',
    'image_banner': 'assets/gameslogos-banner/Sprite Fantasia.jpg'
  },
  {
    'name': 'Dota 2',
    'image': 'assets/gameslogos/Dota 2.jpg',
    'image_banner': 'assets/gameslogos-banner/Dota 2.jpg'
  },
  {
    'name': 'Free Fire',
    'image': 'assets/gameslogos/Free Fire.jpg',
    'image_banner': 'assets/gameslogos-banner/Free Fire.jpg'
  },
  {
    'name': 'Viu',
    'image': 'assets/gameslogos/Viu.png',
    'image_banner': 'assets/gameslogos-banner/Viu.jpg'
  },
  {
    'name': 'Borderlands 3',
    'image': 'assets/gameslogos/Borderlands 3.png',
    'image_banner': 'assets/gameslogos-banner/Borderlands 3.jpg'
  },
  {
    'name': 'The Outer Worlds',
    'image': 'assets/gameslogos/The Outer Worlds.jpg',
    'image_banner': 'assets/gameslogos-banner/The Outer Worlds.jpg'
  },
  {
    'name': "Sid Meier's Civilization VI",
    'image': "assets/gameslogos/Sid Meier's Civilization VI.jpg",
    'image_banner': "assets/gameslogos-banner/Sid Meier's Civilization VI.jpg"
  },
  {
    'name': 'Nintendo eShop (US)',
    'image': 'assets/gameslogos/Nintendo eShop (US).png',
    'image_banner': 'assets/gameslogos-banner/Nintendo eShop (US).jpg'
  },
  {
    'name': 'OK Cupid',
    'image': 'assets/gameslogos/OK Cupid.png',
    'image_banner': 'assets/gameslogos-banner/OK Cupid.jpg'
  },
  {
    'name': 'PlayStation Network Vouchers',
    'image': 'assets/gameslogos/PlayStation Network Vouchers.jpg',
    'image_banner': 'assets/gameslogos-banner/PlayStation Network Vouchers.jpg'
  },
  {
    'name': 'Xbox Gift Card (US)',
    'image': 'assets/gameslogos/Xbox Gift Card (US).png',
    'image_banner': 'assets/gameslogos-banner/Xbox Gift Card (US).jpg'
  },
  {
    'name': 'Minecraft',
    'image': 'assets/gameslogos/Minecraft.jpg',
    'image_banner': 'assets/gameslogos-banner/Minecraft.png'
  }
];
