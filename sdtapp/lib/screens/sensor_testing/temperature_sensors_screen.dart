import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/hive_database.dart';

// DODAN IMPORT KOJI JE NEDOSTAJAO:
// Bez ovoga, datoteka ne zna što je 'LiveData' klasa.
import '../../data/models.dart';

import '../../models/sensor_data.dart';
import '../../services/websocket_service.dart';

class TemperatureSensorsScreen extends StatefulWidget {
  const TemperatureSensorsScreen({super.key});

  @override
  State<TemperatureSensorsScreen> createState() =>
      _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  final SdmTService _sdmtService = SdmTService();

  @override
  void initState() {
    super.initState();
    _sdmtService.connect();
  }

  @override
  void dispose() {
    _sdmtService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Data & History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<LiveData>(
                      valueListenable: _sdmtService.liveDataNotifier,
                      builder: (context, liveData, child) {
                        if (!_sdmtService.isConnectedNotifier.value) {
                          return const Text(
                            'Connecting to device...',
                            style: TextStyle(
                                fontSize: 24, fontStyle: FontStyle.italic),
                          );
                        }

                        // ISPRAVAK: Prikazujemo '0.0' ako je podatak null,
                        // umjesto da se aplikacija sruši.
                        final temp = liveData.coolantTemp;

                        return Text(
                          '${temp.toStringAsFixed(1)} °C',
                          style: const TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sensor History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 2.0,
                child: FutureBuilder<List<SensorData>>(
                  future: HiveDatabase.instance.getAllSensorData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No history data.'));
                    }
                    final dataList = snapshot.data!;
                    return ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        final item = dataList[index];
                        return ListTile(
                          title: Text(
                              '${item.sensorName}: ${item.temperature.toStringAsFixed(2)}°C'),
                          subtitle: Text(DateFormat('yyyy-MM-dd – HH:mm:ss')
                              .format(item.timestamp)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
