import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../screens/settings_screen.dart'; // <-- DODAJ OVAJ IMPORT

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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ValueListenableBuilder<bool>(
              valueListenable: sdmTService.isConnectedNotifier,
              builder: (context, isConnected, child) {
                return IconButton(
                  icon: Icon(
                    Icons.wifi,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    sdmTService.connect();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pokušavam se ponovno spojiti...')),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 40),
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
        // AŽURIRANA onPressed METODA:
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    );
  }
}
