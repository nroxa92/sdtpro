import 'package:flutter/material.dart';
import 'package:sdmt_final/models/live_data.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class LiveDataScreen extends StatelessWidget {
  const LiveDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Data"),
      ),
      body: ValueListenableBuilder<LiveData>(
        valueListenable: SdmTService.instance.liveDataNotifier,
        builder: (context, data, child) {
          return GridView.count(
            crossAxisCount: 2, // Dva stupca
            childAspectRatio: 2.5, // Omjer širine i visine pločica
            padding: const EdgeInsets.all(8.0),
            children: [
              _DataTile(title: "RPM", value: data.rpm.toStringAsFixed(0)),
              _DataTile(title: "Gas", value: "${data.throttle.toStringAsFixed(1)} %"),
              _DataTile(title: "Brzina", value: "${data.speed.toStringAsFixed(1)} km/h"),
              _DataTile(title: "Gorivo", value: "${data.fuel.toStringAsFixed(1)} %"),
              _DataTile(title: "Temp. Vode (ECT)", value: "${data.ect.toStringAsFixed(1)} °C"),
              _DataTile(title: "Temp. Ulja (EOT)", value: "${data.eot.toStringAsFixed(1)} °C"),
              _DataTile(title: "Temp. Zraka (MAT)", value: "${data.mat.toStringAsFixed(1)} °C"),
              _DataTile(title: "Temp. Ispuha (EGT)", value: "${data.egt.toStringAsFixed(1)} °C"),
              _DataTile(title: "Tlak Usisa (MAP)", value: "${data.map.toStringAsFixed(1)} hPa"),
            ],
          );
        },
      ),
    );
  }
}

// Pomoćni widget za prikaz jedne pločice s podatkom
class _DataTile extends StatelessWidget {
  final String title;
  final String value;
  const _DataTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              value.contains("-1") ? "N/A" : value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}