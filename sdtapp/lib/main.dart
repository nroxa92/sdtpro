import 'package:flutter/material.dart';

// NOVI import za Hive bazu
import 'package:sdtapp/data/hive_database.dart';

import 'package:sdtapp/screens/main_menu/main_menu_screen.dart';
import 'package:sdtapp/theme/app_theme.dart';

void main() async {
  // Osigurava da je Flutter spreman
  WidgetsFlutterBinding.ensureInitialized();

  // ISPRAVLJENO: Sada pozivamo inicijalizaciju za Hive, koja je sigurna!
  await HiveDatabase.instance.init();

  // Pokrećemo aplikaciju
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sdtapp',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainMenuScreen(),
    );
  }
}
