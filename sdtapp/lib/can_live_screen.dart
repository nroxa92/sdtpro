// lib/can_live_screen.dart - FINALNA VERZIJA ZA IBR I LISTU
import 'package:flutter/material.dart';
import 'models.dart';
import 'websocket_service.dart';
import 'main_scaffold.dart';

// Pomoćni widget za prikaz pojedinačnog mjerenja (DataTile)
class DataTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const DataTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CanLiveScreen extends StatelessWidget {
  const CanLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sdmTService = SdmTService();

    // Dodajemo title argument u MainScaffold
    return MainScaffold(
      title: 'CAN Bus Live Data',
      appBar: AppBar(title: const Text('CAN Bus Live Data')),
      body: ValueListenableBuilder<CanLiveData>(
        valueListenable: sdmTService.canLiveDataNotifier,
        builder: (context, canData, child) {
          // PROMJENA (Točka 10): Koristimo ListView umjesto GridView
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              DataTile(
                label: 'RPM',
                value: canData.rpm.toStringAsFixed(0),
                unit: 'rpm',
                color:
                    canData.rpm > 5000 ? Colors.redAccent : Colors.greenAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Temp. Vode (ECT)',
                value: canData.coolantTemp.toStringAsFixed(1),
                unit: '°C',
                color:
                    canData.coolantTemp > 95 ? Colors.redAccent : Colors.yellow,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Brzina',
                value: canData.speedKmh.toStringAsFixed(0),
                unit: 'km/h',
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Gas (Throttle)',
                value: canData.throttlePercent.toStringAsFixed(1),
                unit: '%',
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'MAP Tlak',
                value: canData.mapKpa.toStringAsFixed(0),
                unit: 'hPa',
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Temp. Ulja (EOT)',
                value: canData.oilTemp.toStringAsFixed(1),
                unit: '°C',
                color: canData.oilTemp > 120 ? Colors.red : Colors.lightGreen,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Razina Goriva',
                value: canData.fuelLevel.toStringAsFixed(0),
                unit: '%',
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Temp. Ispuha (EGT)',
                value: canData.exhaustTemp.toStringAsFixed(0),
                unit: '°C',
                color: Colors.pinkAccent,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Temp. Usisa (MAT)',
                value: canData.intakeTemp.toStringAsFixed(1),
                unit: '°C',
                color: Colors.cyan,
              ),
              const SizedBox(height: 8),

              DataTile(
                label: 'Napon Bat.',
                value: canData.batteryVoltage.toStringAsFixed(1),
                unit: 'V',
                color:
                    canData.batteryVoltage < 11.5 ? Colors.red : Colors.yellow,
              ),
              const SizedBox(height: 8),

              // ISPRAVAK GREŠKE: Mjenjač/Gear zamijenjen s iBR Pozicijom
              DataTile(
                label: 'iBR Pozicija',
                value: canData.ibrPosition.toStringAsFixed(1),
                unit: '',
                color: Colors.lightBlue,
              ),
            ],
          );
        },
      ),
    );
  }
}
