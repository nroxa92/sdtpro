// lib/can_live_screen.dart - KOMPLETAN DASHBOARD ZA LIVE CAN PODATKE
import 'package:flutter/material.dart';
import 'models.dart';
import 'websocket_service.dart';
import 'main_scaffold.dart';

// Pomoćni widget za prikaz pojedinačnog mjerenja
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
    // Koristimo SdmTService Singleton
    final sdmTService = SdmTService();

    return MainScaffold(
      appBar: AppBar(title: const Text('CAN Bus Live Data')),
      body: ValueListenableBuilder<CanLiveData>(
        valueListenable: sdmTService.canLiveDataNotifier,
        builder: (context, canData, child) {
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              // 1. OKRETAJI MOTORA (RPM)
              DataTile(
                label: 'RPM',
                value: canData.rpm.toStringAsFixed(0),
                unit: 'rpm',
                color:
                    canData.rpm > 5000 ? Colors.redAccent : Colors.greenAccent,
              ),

              // 2. TEMPERATURA VODE (ECT)
              DataTile(
                label: 'Temp. Vode (ECT)',
                value: canData.coolantTemp.toStringAsFixed(1),
                unit: '°C',
                color:
                    canData.coolantTemp > 95 ? Colors.redAccent : Colors.yellow,
              ),

              // 3. BRZINA (SPEED)
              DataTile(
                label: 'Brzina',
                value: canData.speedKmh.toStringAsFixed(0),
                unit: 'km/h',
                color: Colors.blueAccent,
              ),

              // 4. GAS (THROTTLE)
              DataTile(
                label: 'Gas (Throttle)',
                value: canData.throttlePercent.toStringAsFixed(1),
                unit: '%',
                color: Colors.orangeAccent,
              ),

              // 5. TLAK U USISNOJ GRANI (MAP)
              DataTile(
                label: 'MAP Tlak',
                value: canData.mapKpa.toStringAsFixed(0),
                unit: 'hPa',
                color: Colors.tealAccent,
              ),

              // 6. TEMPERATURA ULJA (EOT)
              DataTile(
                label: 'Temp. Ulja (EOT)',
                value: canData.oilTemp.toStringAsFixed(1),
                unit: '°C',
                color: canData.oilTemp > 120 ? Colors.red : Colors.lightGreen,
              ),

              // 7. RAZINA GORIVA
              DataTile(
                label: 'Razina Goriva',
                value: canData.fuelLevel.toStringAsFixed(0),
                unit: '%',
                color: Colors.purpleAccent,
              ),

              // 8. TEMPERATURA ISPUHA (EGT)
              DataTile(
                label: 'Temp. Ispuha (EGT)',
                value: canData.exhaustTemp.toStringAsFixed(0),
                unit: '°C',
                color: Colors.pinkAccent,
              ),

              // 9. TEMP. USISA (MAT)
              DataTile(
                label: 'Temp. Usisa (MAT)',
                value: canData.intakeTemp.toStringAsFixed(1),
                unit: '°C',
                color: Colors.cyan,
              ),

              // 10. NAPON AKUMULATORA
              DataTile(
                label: 'Napon Bat.',
                value: canData.batteryVoltage.toStringAsFixed(1),
                unit: 'V',
                color:
                    canData.batteryVoltage < 11.5 ? Colors.red : Colors.yellow,
              ),

              // Dodajte još jednu pločicu za mjenjač (Gear) ako ga hardver šalje
              DataTile(
                label: 'Mjenjač',
                value: canData.gear.toString(),
                unit: '',
                color: Colors.lightBlue,
              ),
            ],
          );
        },
      ),
      title: '',
    );
  }
}
