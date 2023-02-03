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

<<<<<<< HEAD
bool isLoggedIn = true;
=======
bool isLoggedIn = false;
>>>>>>> main-page-fix

bool LVisible = false;
bool RVisible = false;
var pixelRatio = window.devicePixelRatio;
var logicalScreenSize = window.physicalSize / pixelRatio;
var logicalWidth = logicalScreenSize.width;

final List<Map<String, dynamic>> shopList = [
  {
    'game': 'Mobile Legends',
    'shops': ['7/11', 'Ministop', 'Diskounted']
  },
  {
    'game': 'Valorant',
    'shops': ['Diskounted', 'Ministop']
  },
  {
    'game': 'Leauge of Legends: Wild RIft',
    'shops': ['Ministop']
  },
  {
    'game': 'Call of Duty Mobile',
    'shops': ['7/11', 'Ministop']
  },
  
];
final List<Map<String, dynamic>> gameShop = [
  {
    'shop-name': 'Diskounted',
    'mop': [
      'assets/images/MoP/GCash.png',
      'assets/images/MoP/PayMaya.png',
      'assets/images/MoP/metrobank.png',
      'assets/images/MoP/unionbank.png'
    ],
    'games-price-rate': [
      {
        'Mobile Legends': [
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
        ],
        'Valorant': [
          '₱250 : 600 💎',
          '₱350 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎'
        ],
        'Leauge of Legends: Wild RIft': [
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎'
        ],
      }
    ]
  },
  {
    'shop-name': '7/11',
    'mop': ['assets/images/MoP/GCash.png', 'assets/images/MoP/unionbank.png'],
    'games-price-rate': [
      {
        'Mobile Legends': [
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎'
        ],
        'Call of Duty Mobile': [
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎'
        ],
        'Leauge of Legends: Wild RIft': [
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎'
        ],
      }
    ]
  },
  {
    'shop-name': 'Ministop',
    'mop': [
      'assets/images/MoP/metrobank.png',
      'assets/images/MoP/unionbank.png'
    ],
    'games-price-rate': [
      {
        'Mobile Legends': [
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
          '₱150 : 500 💎',
        ],
        'Valorant': [
          '₱250 : 600 💎',
          '₱350 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎',
          '₱250 : 600 💎'
        ],
        'Call of Duty Mobile': [
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎',
          '₱350 : 700 💎'
        ],
        'Leauge of Legends: Wild RIft': [
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎',
          '₱450 : 800 💎'
        ],
      }
    ]
  }
];
