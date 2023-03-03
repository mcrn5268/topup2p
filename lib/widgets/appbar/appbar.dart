import 'package:flutter/material.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/widgets/appbar/allwidgets.dart';
import 'package:topup2p/widgets/appbar/signoutbutton.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget(this.home, this.search, this.isloggedin,
      {this.fromProfile, this.fromGameSellScreen, super.key});
  final bool home;
  final bool search;
  final bool isloggedin;
  final bool? fromProfile;
  final List<Item>? fromGameSellScreen;
  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          (fromProfile != null) ? Colors.blueGrey : Colors.transparent,
      leading: leadingIcon(context),
      shape: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: SafeArea(
            child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (search == true) ...[
                const SearchButton(),
              ],
              if (isloggedin == true) ...[
                MessageButton(fromProfile: fromProfile),
                if (fromProfile == true) ...[
                  const SignoutButton(),
                ] else ...[
                  const ProfileButton(),
                ]
              ] else ...[
                const LogInButton(),
              ],
            ],
          ),
        )),
      ),
    );
  }

  Widget leadingIcon(BuildContext context) {
    if (home == false) {
      return IconButton(
          onPressed: () {
            if (fromGameSellScreen != null) {
              Navigator.pop(context, fromGameSellScreen);
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: (fromProfile != null) ? Colors.white : Colors.black,
          ));
    } else {
      return const LogoButton();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(66);
}
