import 'package:flutter/material.dart';

// Sada ova datoteka postoji i import će raditi.
import 'theme/app_theme.dart';

// Putanja do glavnog izbornika je ispravna.
import 'screens/main_menu_screen.dart';

// Import za bazu nam i dalje ne treba za ovaj test.
// import 'data/sensor_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ostavljamo KLJUČNU LINIJU zakomentiranu za test.
  // await SensorDatabase.instance.init();

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
