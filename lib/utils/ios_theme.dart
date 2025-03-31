import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSTheme {
  // Colors
  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color secondaryColor = CupertinoColors.systemGreen;
  static const Color backgroundColor = CupertinoColors.systemBackground;
  static const Color textColor = CupertinoColors.label;

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );

  // Apply iOS theme to the app
  static ThemeData getTheme(bool isDark) {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor:
          isDark
              ? CupertinoColors.systemBackground.darkColor
              : CupertinoColors.systemBackground.color,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark
                ? CupertinoColors.systemBackground.darkColor
                : CupertinoColors.systemBackground.color,
        foregroundColor:
            isDark
                ? CupertinoColors.label.darkColor
                : CupertinoColors.label.color,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(titleLarge: titleStyle, bodyLarge: bodyStyle),
      fontFamily: '.SF Pro Text',
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
  }
}
