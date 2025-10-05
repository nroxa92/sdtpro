import 'package:flutter/material.dart';
// Uvezite sve potrebne datoteke
import 'hive_database.dart';
import 'main_menu_screen.dart';
import 'app_theme.dart';
import 'sensor_data.dart'; // Potrebno za AppRoutes
import 'settings_screen.dart'; // Potrebno za rutu /settings
// Budući da AboutScreen mora raditi (poziva ga SettingsScreen), uvest ćemo i njega.
import 'about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Poziv init-a za Hive (koristimo placeholder dok se ne implementira Hive)
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

      // Koristimo 'home' za glavni ekran
      home: const MainMenuScreen(),

      // DEFINIRANJE NAMED ROUTES (RJEŠAVANJE CRASHA)
      // Svaki ekran koji se poziva preko pushNamed() mora biti ovdje definiran.
      routes: {
        // RUTA ZA SETTINGS (Rješava rušenje pri kliku na gumb)
        AppRoutes.settings: (context) => const SettingsScreen(),

        // RUTA ZA ABOUT (Poziva se unutar Settings ekrana)
        '/about': (context) => const AboutScreen(),

        // NAPOMENA: Ovdje možete dodati sve rute koje ste definirali u AppRoutes
      },
    );
  }
}
