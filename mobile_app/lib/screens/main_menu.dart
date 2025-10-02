import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/data/sensor_database.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SdmTService.instance.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = groupedSensors.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SeaDoo miniTool PRO'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _MainMenuButton(
                      icon: category == TestCategory.sensors ? Icons.memory : Icons.hub,
                      label: category.displayName,
                      onPressed: () {
                        // Ovdje je greška, ispravljeno:
                        // Za TestCategory.sensors treba ići na /testList
                        if (category == TestCategory.sensors) {
                           Navigator.pushNamed(context, '/testList', arguments: category);
                        } else { // Za TestCategory.can ide na /liveData
                           Navigator.pushNamed(context, '/liveData');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),

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
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStatusBar(),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      color: const Color(0xFF333333),
      padding: const EdgeInsets.all(8.0).copyWith(bottom: MediaQuery.of(context).padding.bottom),
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
          _StatusItem(icon: Icons.hub, label: "CAN Bus", value: "-"),
          _StatusItem(icon: Icons.battery_charging_full, label: "Baterija", value: "-"),
        ],
      ),
    );
  }
}


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
        backgroundColor: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
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