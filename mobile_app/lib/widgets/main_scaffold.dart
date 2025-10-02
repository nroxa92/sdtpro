import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;

  const MainScaffold({
    super.key,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: _buildBottomControls(context),
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