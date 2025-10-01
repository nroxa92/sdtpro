import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdmt_final/screens/about.dart';
import 'package:sdmt_final/screens/main_menu.dart';
import 'package:sdmt_final/screens/settings.dart';
import 'package:sdmt_final/screens/test.dart';
import 'package:sdmt_final/screens/test_list.dart';
import 'package:sdmt_final/services/websocket_service.dart';

// Glavna funkcija koja pokreće aplikaciju
void main() {
  runApp(
    // Provider čini SdmTService dostupnim u cijeloj aplikaciji
    Provider(
      create: (_) => SdmTService.instance,
      child: const MiniToolApp(),
    ),
  );
}

class MiniToolApp extends StatelessWidget {
  const MiniToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaDoo miniTool',
      theme: ThemeData.dark().copyWith(
        // Ovdje možete dodati specifične boje i stilove za vašu temu
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF222222),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF333333),
          elevation: 0,
        ),
        cardColor: const Color(0xFF333333),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/testList': (context) => const TestListScreen(),
        '/testScreen': (context) => const TestScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}