import 'package:flutter/material.dart';
import '../services/websocket_service.dart'; // Importaj SdmTService

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final SdmTService sdmTService = SdmTService(); // Instanca servisa

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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // --- WIFI IKONA ---
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.isConnectedNotifier,
              builder: (context, isConnected, child) {
                return IconButton(
                  icon: Icon(
                    Icons.wifi,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    // Logika za ponovno spajanje
                    sdmTService.connect();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pokušavam se ponovno spojiti...')),
                    );
                  },
                );
              },
            ),

            // --- SPACER ---
            const SizedBox(width: 40), // Prostor za srednji gumb

            // --- CAN STATUS IKONA ---
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.canActivityNotifier,
              builder: (context, isActive, child) {
                return Icon(
                  Icons.directions_car,
                  color: isActive ? Colors.green : Colors.grey,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.settings),
        onPressed: () {},
      ),
    );
  }
}
