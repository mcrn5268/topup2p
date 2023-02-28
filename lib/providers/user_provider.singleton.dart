import 'package:topup2p/providers/user_provider.dart';

class UserProviderSingleton {
  static final UserProviderSingleton _singleton = UserProviderSingleton._internal();
  UserProvider? _userProvider;

  factory UserProviderSingleton() {
    return _singleton;
  }

  UserProviderSingleton._internal() {
    _userProvider = UserProvider();
  }

  UserProvider getUserProvider() {
    return _userProvider!;
  }
}
