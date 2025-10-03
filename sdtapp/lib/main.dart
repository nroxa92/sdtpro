import 'package:flutter/material.dart';
import 'package:sdt_final/screens/main_menu_screen.dart';
// Uklonili smo import za bazu jer je poziv zakomentiran.
// import 'package:sdtapp/data/sensor_database.dart';

// ISPRAVLJEN IMPORT: Sada pokazuje na tvoj glavni izbornik.
import 'package:sdtapp/screens/main_menu_screen.dart';
import 'package:sdtapp/theme/app_theme.dart';

void main() async {
  // Ova linija je i dalje potrebna jer mnogi paketi (čak i ako ih ne zovemo
  // direktno ovdje) mogu zahtijevati da je Flutter engine spreman.
  WidgetsFlutterBinding.ensureInitialized();

  // --- TEST ---
  // Linija za inicijalizaciju baze ostaje zakomentirana. Ovo je i dalje
  // najsumnjiviji dio koda koji uzrokuje rušenje.
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

      // ISPRAVLJEN POČETNI EKRAN:
      // Sada aplikacija ispravno kreće od tvog glavnog izbornika.
      home: const MainMenuScreen(),
    );
  }
}

class AppTheme {
  static ThemeData? get darkTheme => null;

  static ThemeData? get lightTheme => null;
}
