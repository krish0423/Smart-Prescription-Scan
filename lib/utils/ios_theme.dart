import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSThemeData {
  final Brightness brightness;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color dividerColor;

  IOSThemeData({
    required this.brightness,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.dividerColor,
  });

  static IOSThemeData light() {
    return IOSThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF4A90E2),
      backgroundColor: const Color(0xFFF5F7FA),
      cardColor: Colors.white,
      textColor: Colors.black,
      secondaryTextColor: Colors.grey.shade700,
      dividerColor: Colors.grey.shade300,
    );
  }

  static IOSThemeData dark() {
    return IOSThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2C78D4),
      backgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      textColor: Colors.white,
      secondaryTextColor: Colors.grey.shade300,
      dividerColor: Colors.grey.shade800,
    );
  }

  CupertinoThemeData toCupertinoThemeData() {
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      barBackgroundColor: cardColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: TextStyle(color: textColor, fontFamily: 'Poppins'),
        navTitleTextStyle: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: primaryColor,
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        actionTextStyle: TextStyle(
          color: primaryColor,
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        pickerTextStyle: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
  }
}

class IOSThemeProvider extends StatelessWidget {
  final Widget child;
  final Brightness brightness;

  const IOSThemeProvider({
    Key? key,
    required this.child,
    required this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData =
        brightness == Brightness.dark
            ? IOSThemeData.dark()
            : IOSThemeData.light();

    return CupertinoTheme(data: themeData.toCupertinoThemeData(), child: child);
  }
}
