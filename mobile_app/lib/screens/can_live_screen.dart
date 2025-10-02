import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/services/websocket_service.dart';
import 'package:sdmt_final/widgets/main_scaffold.dart'; // <-- NOVI IMPORT

class CanLiveScreen extends StatefulWidget {
  const CanLiveScreen({super.key});
  @override
  State<CanLiveScreen> createState() => _CanLiveScreenState();
}

class _CanLiveScreenState extends State<CanLiveScreen> {
  // ... sav kod unutar state klase ostaje isti ...

  @override
  Widget build(BuildContext context) {
    // Sada vraćamo MainScaffold umjesto običnog Scaffold-a
    return MainScaffold(
      appBar: AppBar(title: const Text('CAN Live Data')),
      body: ValueListenableBuilder<LiveData>(
        valueListenable: sdmTService.liveDataNotifier,
        builder: (context, data, child) {
          return Column(
            children: [
              _buildDataTable(data),
              Expanded(child: _buildChart()),
            ],
          );
        },
      ),
    );
  }
  
  // ... sve ostale funkcije (_buildDataTable, _buildChart itd.) ostaju iste ...
}