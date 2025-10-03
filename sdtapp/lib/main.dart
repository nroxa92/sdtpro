import 'package:flutter/material.dart';
import 'hive_database.dart'; // <-- ISPRAVLJENO
import 'main_menu_screen.dart'; // <-- ISPRAVLJENO
import 'app_theme.dart'; // <-- ISPRAVLJENO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.instance.init();
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
