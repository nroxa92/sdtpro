import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // Statusi ostaju isti, ali se više ne ažuriraju ovdje,
  // već će to raditi LiveDataScreen.
  // Ovdje ih ostavljamo ako ih statusna traka i dalje treba.
  // Za sada, ova datoteka više ne treba 'initState' i 'jsonDecode'.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeaDoo miniTool PRO'),
        centerTitle: true, // Centriraj naslov
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Veliki gumbi ---
            _MainMenuButton(
              icon: Icons.memory, // Ikona za senzore
              label: 'Senzori i Komponente',
              onPressed: () => Navigator.pushNamed(context, '/testList'),
            ),
            const SizedBox(height: 16),
            _MainMenuButton(
              icon: Icons.hub, // Ikona za CAN
              label: 'CAN Dijagnostika',
              onPressed: () => Navigator.pushNamed(context, '/liveData'),
            ),
            
            const Spacer(), // Gura donje gumbe na dno

            // --- Manji gumbi ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SmallMenuButton(
                  icon: Icons.settings,
                  label: 'Postavke',
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
                _SmallMenuButton(
                  icon: Icons.info_outline,
                  label: 'O Aplikaciji',
                  onPressed: () => Navigator.pushNamed(context, '/about'),
                ),
                _SmallMenuButton(
                  icon: Icons.exit_to_app,
                  label: 'Izlaz',
                  onPressed: () {
                    SdmTService.instance.disconnect();
                    SystemNavigator.pop(); // Ispravan način za zatvaranje aplikacije
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      // Statusna traka ostaje ista, maknuta iz Columna i stavljena u Scaffold
      bottomNavigationBar: _buildStatusBar(), 
    );
  }

  // Widget za statusnu traku ostaje isti kao prije
  Widget _buildStatusBar() {
    return Container(
      color: const Color(0xFF333333),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: SdmTService.instance.isConnectedNotifier,
            builder: (context, isConnected, child) {
              return _StatusItem(
                icon: Icons.wifi,
                label: "Wi-Fi",
                value: isConnected ? "Spojen" : "Nema veze",
                color: isConnected ? Colors.greenAccent : Colors.redAccent,
              );
            },
          ),
          // Ove iteme ćemo kasnije povezati na LiveData
          _StatusItem(icon: Icons.hub, label: "CAN Bus", value: "-"),
          _StatusItem(icon: Icons.battery_charging_full, label: "Baterija", value: "-"),
        ],
      ),
    );
  }
}


// --- Pomoćni widgeti za gumbe ---

class _MainMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MainMenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32),
      label: Text(label, style: const TextStyle(fontSize: 20)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SmallMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SmallMenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          onPressed: onPressed,
          color: Colors.white70,
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// Widget za item u statusnoj traci (nepromijenjen)
class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatusItem({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}