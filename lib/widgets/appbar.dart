import 'package:flutter/material.dart';
import 'package:topup2p/widgets/appbarwidgets/allwidgets.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget{
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Expanded(
              child: LogoButton(),
            ),
            SearchButton(),
            MessageButton(),
            SignupButton(),
          ],
        ),
      ),
    );
  }
  
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
