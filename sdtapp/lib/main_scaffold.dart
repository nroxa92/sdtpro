// lib/main_scaffold.dart - REVIDIRANA VERZIJA (Uklanjanje viška i Home ikone)
import 'package:flutter/material.dart';
import 'websocket_service.dart';
import 'sensor_data.dart';
// Uklanjamo import za settings_screen.dart jer koristimo AppRoutes.settings

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AppBar? appBar;
  final SdmTService sdmTService = SdmTService();

  MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koristimo AppBar koji je proslijeđen (ako postoji)
      appBar: appBar ?? AppBar(title: Text(title)),
      body: body,

      // AŽURIRANA DONJA TRAKA: SAMO WIFI, SETTINGS I CAN (Točke 1, 5)
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 50, // Diskretnija visina (Točka 4)
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // --- WIFI IKONA ---
              ValueListenableBuilder<bool>(
                valueListenable: sdmTService.isConnectedNotifier,
                builder: (context, isConnected, child) {
                  return IconButton(
                    iconSize: 24.0,
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

              // --- NOVI SETTINGS GUMB (Sada jedini navigacijski gumb) ---
              IconButton(
                iconSize: 24.0,
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Settings gumb SADA RADI i vodi na Settings rutu
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),

              // --- CAN STATUS IKONA ---
              ValueListenableBuilder<bool>(
                valueListenable: sdmTService.canActivityNotifier,
                builder: (context, isActive, child) {
                  return Icon(
                    Icons.cable, // Ikona za CAN/Dijagnostiku (Točka 5)
                    size: 24.0,
                    color: isActive ? Colors.green : Colors.red,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
