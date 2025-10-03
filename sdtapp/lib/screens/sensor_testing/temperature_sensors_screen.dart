import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/hive_database.dart'; // <-- ISPRAVLJENO
import '../../models/sensor_data.dart'; // <-- ISPRAVLJENO
import '../../services/websocket_service.dart'; // <-- ISPRAVLJENO

// ... ostatak koda u ovoj datoteci je isti kao što sam ti poslao ranije ...
// Samo su gornji importi promijenjeni.
class TemperatureSensorsScreen extends StatefulWidget {
  const TemperatureSensorsScreen({super.key});

  @override
  State<TemperatureSensorsScreen> createState() =>
      _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  late WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _webSocketService.connect('ws://192.168.1.100:81');
  }

  @override
  void dispose() {
    _webSocketService.dispose();
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
            // Live Data Section
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Temperature',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                      stream: _webSocketService.responses,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text(
                            'Connecting to device...',
                            style: TextStyle(
                                fontSize: 24, fontStyle: FontStyle.italic),
                          );
                        }

                        // Spremanje testnih podataka
                        ElevatedButton(
                            onPressed: () {
                              final data = SensorData(
                                  sensorName: 'Test Sensor',
                                  temperature: 123.45,
                                  timestamp: DateTime.now());
                              HiveDatabase.instance.insertSensorData(data);
                              setState(() {}); // Osvježi FutureBuilder
                            },
                            child: const Text('Spremi Test Podatak'));

                        return Text(
                          snapshot.data.toString(),
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

            // History Section
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
                          subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm:ss')
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
