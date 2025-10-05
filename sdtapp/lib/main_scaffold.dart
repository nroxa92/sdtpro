import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'websocket_service.dart'; // ISPRAVAK: Importamo ispravnu datoteku
import 'app_routes.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AppBar? appBar;

  // Kreiramo instancu servisa
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
      appBar: appBar ?? AppBar(title: Text(title)),
      body: body,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey[900],
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // --- 1. WIFI IKONA ---
              ValueListenableBuilder<bool>(
                valueListenable: sdmTService.isConnectedNotifier,
                builder: (context, isConnected, child) {
                  return IconButton(
                    icon: Icon(Icons.wifi,
                        color: isConnected ? Colors.blue : Colors.red),
                    tooltip: isConnected ? 'Spojeno' : 'Spoji se na SDT BOX',
                    onPressed: () {
                      if (!isConnected) {
                        sdmTService.connect();
                      }
                    },
                  );
                },
              ),

              // --- 2. CAN IKONA ---
              ValueListenableBuilder<bool>(
                valueListenable: sdmTService.canActivityNotifier,
                builder: (context, isActive, child) {
                  return Icon(
                    Icons.cable,
                    color: isActive ? Colors.green : Colors.red,
                    semanticLabel: 'CAN Status',
                  );
                },
              ),

              // --- 3. POD IKONA (Sada dinamična) ---
              ValueListenableBuilder<PodStatus>(
                valueListenable: sdmTService.podStatusNotifier,
                builder: (context, status, child) {
                  return Icon(
                    Icons.memory,
                    color: status.color, // Boja se mijenja ovisno o statusu
                    semanticLabel: 'Status POD-a: ${status.name}',
                  );
                },
              ),

              // --- 4. SETTINGS IKONA ---
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Postavke',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),

              // --- 5. EXIT IKONA ---
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                tooltip: 'Zatvori Aplikaciju',
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
