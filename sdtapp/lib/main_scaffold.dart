// lib/main_scaffold.dart - POPRAVLJENA VERZIJA
import 'package:flutter/material.dart';
import 'websocket_service.dart';
import 'settings_screen.dart'; // Uvoz mora biti točan ako se koristi

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  // AppBar je sada opcionalan i čuva se kao dio klase
  final AppBar? appBar;
  final SdmTService sdmTService = SdmTService();

  // Konstruktor je ispravljen: 'appBar' je sada dio klase, a ne samo argument
  MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBar, // AppBar je opcionalan
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koristimo AppBar koji je proslijeđen (ako postoji)
      appBar: appBar ?? AppBar(title: Text(title)),
      body: body,

      // AŽURIRANA DONJA TRAKA
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // --- WIFI IKONA ---
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.isConnectedNotifier,
              builder: (context, isConnected, child) {
                return IconButton(
                  iconSize: 30.0,
                  icon: Icon(
                    Icons.wifi,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    sdmTService.connect();
                  },
                );
              },
            ),

            // --- NOVI SETTINGS GUMB U SREDINI ---
            IconButton(
              iconSize: 35.0,
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Koristimo pushNamed ako je ruta definirana u main.dart, ili MaterialPageRoute
                // Ovdje koristimo MaterialPageRoute jer ne znamo točnu rutu 'settings'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),

            // --- CAN STATUS IKONA ---
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.canActivityNotifier,
              builder: (context, isActive, child) {
                return Icon(
                  Icons.directions_car, // Ikona za CAN/Vozilo
                  size: 30.0,
                  color: isActive ? Colors.green : Colors.red,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
