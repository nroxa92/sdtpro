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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            // Glavni gumbi
            ...categories.map((category) {
              IconData icon;
              String route;
              switch (category) {
                case TestCategory.senzori: icon = Icons.sensors; route = '/testList'; break;
                case TestCategory.in_komponente: icon = Icons.input; route = '/testList'; break;
                case TestCategory.out_komponente: icon = Icons.output; route = '/testList'; break;
                case TestCategory.can_live: icon = Icons.show_chart; route = '/liveData'; break;
                case TestCategory.can_errors: icon = Icons.error_outline; route = '/canErrors'; break;
                case TestCategory.can_testovi: icon = Icons.biotech; route = '/canTests'; break;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _MainMenuButton(
                  icon: icon,
                  label: category.displayName,
                  onPressed: () => Navigator.pushNamed(context, route, arguments: category),
                ),
              );
            }).toList(),
            const Spacer(),
            // Donja traka s ikonama
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final sdmTService = context.watch<SdmTService>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: sdmTService.isConnectedNotifier,
            builder: (context, isConnected, _) => Icon(Icons.wifi, color: isConnected ? Colors.blueAccent : Colors.redAccent, size: 28),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => Navigator.pushNamed(context, '/about')),
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () {
            sdmTService.disconnect();
            SystemNavigator.pop();
          }),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: sdmTService.canActivityNotifier,
            builder: (context, hasActivity, _) => Icon(Icons.hub, color: hasActivity ? Colors.greenAccent : Colors.grey, size: 28),
          ),
        ],
      ),
    );
  }
}
// Ostatak koda za _MainMenuButton ostaje isti