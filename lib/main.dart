import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/core/theme/app_theme.dart';
import 'package:hisaberkhata/feature/home/screen/home_screen.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:hisaberkhata/screens/studentlist.dart';
// import 'package:hisaberkhata/screens/studentprofile.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    final themeIndex = prefs.getInt('theme') ?? 0;
    themeValueNotifier.value = ThemeMode.values[themeIndex];
  });

  runApp(
    AppDataProvider(
      appData: AppData(),
      child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeValueNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const HomeScreen(),
            );
          }),
    ),
  );
}
