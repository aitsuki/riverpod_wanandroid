import 'package:flutter/material.dart';

class TabBarContainer extends StatelessWidget implements PreferredSizeWidget {
  const TabBarContainer({required this.tabBar, this.child, Key? key})
      : super(key: key);

  final TabBar tabBar;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(child: tabBar, fit: FlexFit.tight),
      SizedBox(width: preferredSize.height, child: child!),
    ]);
  }

  @override
  Size get preferredSize {
    return tabBar.preferredSize;
  }
}
