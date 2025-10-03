import 'package:flutter/material.dart';

class AppTheme {
  // Privatni konstruktor da se klasa ne može instancirati
  AppTheme._();

  // Osnovna svijetla tema
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Ovdje možeš dodati još postavki za svijetlu temu
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // Osnovna tamna tema
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // Ovdje možeš dodati još postavki za tamnu temu
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black26,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
