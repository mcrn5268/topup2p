import 'package:flutter/cupertino.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites-items.dart';
import 'dart:ui';

final List<String> productItems = [
  'Mobile Legends',
  'Valorant',
  'Call of Duty Mobile',
  'Leauge of Legends: Wild RIft',
  'Free Fire MAX',
  'Garena Shells',
  'Steam Wallet Code',
  'PUBG Mobile UC Vouchers',
  'Counter Strike: Global Offensive',
  'MU Origin 3',
  'Tinder Voucher Code',
  'Punishing: Gray Raven',
  'MU Origin 2',
  'LifeAfter',
  'Mirage: Perfect Skyline',
  'Basketrio',
  'Be The King: Judge Destiny',
  'ONE PUNCH MAN: The Strongest',
  'Identity V',
  'ZEPETO',
  'Apex Legends Mobile',
  '8 Ball Pool',
  'Legends of Runeterra',
  'Shining Nikki',
  'Super Sus',
  'Tamashi: Rise of Yokai',
  'World War Heroes',
  'Super Mecha Champions',
  'Grand Theft Auto V: Premium Online Edition',
  'MARVEL Super War',
  'WWE 2k22 - Steam',
  'Onmyoji Arena',
  'Dawn Era',
  'Sausage Man',
  'Hyper Front',
  'MARVEL Strike Force',
  'NBA 2k22 Steam',
  'Read Dead Redemption 2',
  "Tiny Tina's Assult on Dragon Keep",
  "Tiny Tina's Wonderlands",
  'Dragon City',
  'EOS Red',
  'The Lord of the Rings: Rise to War',
  'Harry Potter: Puzzle & Speels',
  'Cave Shooter',
  'Club Vegas',
  'Top Eleven',
  'Asphalt 9: Legends',
  'Modern Combat 5: Blackout',
  'Badlanders',
  'Heroes Evolved',
  'Tom and Jerry: Chase',
  'MARVEL Duel',
  'Turbo VPN',
  'Omlet Arcade',
  'Bleach Mobile 3D',
  'Disorder',
  'Captain Tsubasa: Dream Team',
  'Cooking Adventure',
  'Jade Dynasty: New Fantasy',
  'OlliOlli World',
  'Sprite Fantasia',
  'Dota 2',
  'Free Fire',
  'Viu',
  'Borderlands 3',
  'The Outer Worlds',
  "Sid Meier's Civilization VI",
  'Nintendo eShop (US)',
  'OK Cupid',
  'PlayStation Network Vouchers',
  'Xbox Gift Card (US)',
  'Minecraft'
];
late final List<Map<String, dynamic>> theMap = [];
final Map<bool, String> forIcon = {
  true: 'assets/icons/bookmark-icon-yellow.png',
  false: 'assets/icons/bookmark-icon-white.png'
};
late var favoritedList;
final favoritedItems = <FavoriteItems>[];

bool LVisible = false;
bool RVisible = false;
//Size size = WidgetsBinding.instance.window.physicalSize;
var pixelRatio = window.devicePixelRatio;
var logicalScreenSize = window.physicalSize / pixelRatio;
var logicalWidth = logicalScreenSize.width;
//double size = MediaQuery.of(context).size.width;
