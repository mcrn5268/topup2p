import 'package:flutter/material.dart';
import 'package:topup2p/widgets/cons-widgets/appbarwidgets/allwidgets.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget(this.home, this.search, this.isloggedin, {super.key});
  final bool home;
  final bool search;
  final bool isloggedin;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leadingIcon(context),
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (search == true) ...[
                  const SearchButton(),
                ],
                if (isloggedin == true) ...[
                  const MessageButton(),
                  const ProfileButton(),
                ] else ...[
                  const SignupButton(),
                ],
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget leadingIcon(BuildContext context) {
    if (home == false) {
      return IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black));
    } else {
      return const LogoButton();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
