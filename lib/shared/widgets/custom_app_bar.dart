import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? leading; // ✅ Added optional leading parameter
  final VoidCallback? onBackPressed; // ✅ Custom back press handler

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.leading, // ✅ Now properly defined
    this.onBackPressed, // ✅ Custom back handler
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      centerTitle: true,
      leading: leading ?? // ✅ Use custom leading if provided
          (showBackButton
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: onBackPressed ?? () => Navigator.pop(context), // ✅ Use custom back handler
          )
              : null),
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}