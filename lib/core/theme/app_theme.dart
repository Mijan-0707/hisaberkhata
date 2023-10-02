import 'package:flutter/material.dart';

final themeValueNotifier = ValueNotifier(ThemeMode.system);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade200,
    colorScheme: const ColorScheme.light(),
    appBarTheme: appBarTheme(Colors.black),
    dialogTheme: dialogTheme(),
    primaryColor: Colors.amber,
    inputDecorationTheme: inputDecorationTheme(Colors.grey.shade100),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(),
    appBarTheme: appBarTheme(Colors.white),
    dialogTheme: dialogTheme(),
    inputDecorationTheme: inputDecorationTheme(Colors.grey.shade800),
    primaryColor: Colors.amber,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static InputDecorationTheme inputDecorationTheme(Color color) {
    return InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      fillColor: color,
      filled: true,
    );
  }

  static AppBarTheme appBarTheme(Color color) {
    return AppBarTheme(
      actionsIconTheme: IconThemeData(color: color),
      titleTextStyle: TextStyle(color: color, fontSize: 20),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
    );
  }

  static DialogTheme dialogTheme() {
    return const DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
