import 'package:flutter/material.dart';

class MyColors {
  static bool isDarkMode = true;
  static  Color defaultPrimaryColor = Colors.grey[800]!;

  static Color _primaryColor = defaultPrimaryColor;

  static Color get primaryColor => _primaryColor;
  static Color get backgroundColor => isDarkMode ? Colors.grey[900]! : Colors.white;
  static Color get inactiveColor => isDarkMode ? Colors.grey : Colors.grey[300]!;
  static Color get textColor => isDarkMode ? Colors.white : Colors.black;

  static set primaryColor(Color color) {
    _primaryColor = color;
  }
}
