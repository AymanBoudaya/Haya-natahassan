import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/widgets/theme.provider.dart'; // Import your theme provider

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHomePage;
  final String title;

  const CustomAppBar({Key? key, required this.isHomePage, required this.title,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      title: Text(title), // Customize title as needed
      backgroundColor: Colors.green,
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_6), // Light bulb icon for theme toggle
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
        IconButton(onPressed: () {
          themeProvider.increaseFontSize();
        }, icon: Icon(Icons.text_increase)
        ),
        IconButton(onPressed: () {
          themeProvider.decreaseFontSize();
        }, icon: Icon(Icons.text_decrease))
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
