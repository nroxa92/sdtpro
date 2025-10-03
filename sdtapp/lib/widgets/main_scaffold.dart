import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../screens/settings_screen.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final SdmTService sdmTService = SdmTService();

  MainScaffold({
    required this.title,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
      // UKLONJENI FloatingActionButton i njegova lokacija

      // AŽURIRANA DONJA TRAKA
      bottomNavigationBar: BottomAppBar(
        child: Row(
          // Raspoređujemo ikone ravnomjerno po cijeloj širini
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // --- WIFI IKONA ---
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.isConnectedNotifier,
              builder: (context, isConnected, child) {
                return IconButton(
                  iconSize: 30.0, // Malo veća ikona
                  icon: Icon(
                    Icons.wifi,
                    // ISPRAVLJENA LOGIKA BOJE: Zelena za spojeno, crvena za nespojeno
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    sdmTService.connect();
                    // UKLONJENA "SnackBar" poruka
                  },
                );
              },
            ),

            // --- NOVI SETTINGS GUMB U SREDINI ---
            IconButton(
              iconSize: 35.0, // Malo veća ikona
              icon: const Icon(Icons.settings),
              onPressed: () {
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
                  Icons.directions_car,
                  size: 30.0,
                  // ISPRAVLJENA LOGIKA BOJE: Zelena za aktivnost, crvena za neaktivnost
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
