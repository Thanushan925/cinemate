import 'package:flutter/material.dart';

class ThemeManager {
  // default theme for browsing page
  static ThemeData currentTheme = ThemeData.light(); 

  static void setTheme(ThemeData newTheme) {
    currentTheme = newTheme;
  }
}
