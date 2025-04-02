import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading:
            showBackButton
                ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.back),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        trailing:
            actions != null
                ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                : null,
        backgroundColor: CupertinoTheme.of(
          context,
        ).barBackgroundColor.withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: Color(0x1A000000), width: 0.5),
        ),
      );
    } else {
      return AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        actions: actions,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      );
    }
  }
}
