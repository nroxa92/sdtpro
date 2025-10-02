import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/data/sensor_database.dart';
import 'package:sdmt_final/services/websocket_service.dart';
import 'package:sdmt_final/widgets/main_scaffold.dart';

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
    
    return MainScaffold(
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
            ...categories.map((category) {
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _MainMenuButton(
                  icon: icon,
                  label: category.displayName,
                  onPressed: () => Navigator.pushNamed(context, route, arguments: category),
                ),
              );
            }),
            const Spacer(),
          ],
        ),
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
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }
}