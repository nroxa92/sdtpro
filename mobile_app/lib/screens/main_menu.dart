import 'dart:convert';
import 'package:flutter/material.dart'; // Ključni import koji nedostaje
import 'package:sdmt_final/data/sensor_database.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String canStatus = "-";
  String battVoltage = "-";

  @override
  void initState() {
    super.initState();
    SdmTService.instance.messages.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['status'] != null && mounted) {
          setState(() {
            canStatus = data['status']['can']?.toString() ?? "-";
            battVoltage = data['status']['batt']?.toString() ?? "-";
          });
        }
      } catch (e) {
        debugPrint("Poruka nije status: $message");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = groupedSensors.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SDmT - Izbornik'),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.displayName, style: const TextStyle(fontSize: 20)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/testList', arguments: category),
                );
              },
            ),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text('SDmT Meni', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Live Data'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/liveData');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Postavke'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O Aplikaciji'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }

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
          _StatusItem(icon: Icons.hub, label: "CAN Bus", value: canStatus),
          _StatusItem(icon: Icons.battery_charging_full, label: "Baterija", value: battVoltage),
        ],
      ),
    );
  }
}

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