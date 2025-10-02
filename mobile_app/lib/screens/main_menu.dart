import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
      context.read<SdmTService>().connect();
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
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: categories.map((category) {
                IconData icon;
                String route;
                switch (category) {
                  case TestCategory.senzori: icon = Icons.sensors; route = '/testList'; break;
                  case TestCategory.inKomponente: icon = Icons.input; route = '/testList'; break;
                  case TestCategory.outKomponente: icon = Icons.output; route = '/testList'; break;
                  case TestCategory.canLive: icon = Icons.show_chart; route = '/liveData'; break;
                  case TestCategory.canErrors: icon = Icons.error_outline; route = '/canErrors'; break;
                  case TestCategory.canTestovi: icon = Icons.biotech; route = '/canTests'; break;
                }
                return _MainMenuButton(
                  icon: icon,
                  label: category.displayName,
                  onPressed: () => Navigator.pushNamed(context, route, arguments: category),
                );
              }).toList(),
            ),
          ),
          // Donja traka s kontrolama
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final sdmTService = context.watch<SdmTService>();
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: sdmTService.isConnectedNotifier,
            builder: (context, isConnected, _) => IconButton(
              icon: Icon(Icons.wifi, color: isConnected ? Colors.blue : Colors.red),
              tooltip: isConnected ? 'Spojen' : 'Pokušaj ponovno spajanje',
              onPressed: () { if (!isConnected) sdmTService.connect(); },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.settings), tooltip: 'Postavke', onPressed: () => Navigator.pushNamed(context, '/settings')),
              IconButton(icon: const Icon(Icons.info_outline), tooltip: 'O Aplikaciji', onPressed: () => Navigator.pushNamed(context, '/about')),
              IconButton(icon: const Icon(Icons.exit_to_app), tooltip: 'Izlaz', onPressed: () {
                sdmTService.disconnect();
                SystemNavigator.pop();
              }),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: sdmTService.canActivityNotifier,
            builder: (context, hasActivity, _) => Icon(Icons.hub, color: hasActivity ? Colors.green : Colors.red),
          ),
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}