import 'package:flutter/material.dart';
import 'websocket_service.dart';
import 'main_scaffold.dart';
import 'models.dart';

class PodDashboardScreen extends StatefulWidget {
  const PodDashboardScreen({super.key});

  @override
  State<PodDashboardScreen> createState() => _PodDashboardScreenState();
}

class _PodDashboardScreenState extends State<PodDashboardScreen> {
  // Pristupamo našem singleton servisu
  final SdmTService _sdmTService = SdmTService();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'POD Dashboard',
      appBar: AppBar(
        title: const Text('POD Dashboard'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<PodStatus>(
        valueListenable: _sdmTService.podStatusNotifier,
        builder: (context, podStatus, child) {
          return Column(
            children: [
              // 1. STATUSNA TRAKA NA VRHU
              _buildStatusHeader(context, podStatus),

              // 2. GLAVNI SADRŽAJ EKRANA
              Expanded(
                child: _buildPodContent(context, podStatus),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget za prikaz statusne trake (ostaje isti)
  Widget _buildStatusHeader(BuildContext context, PodStatus podStatus) {
    return Container(
      width: double.infinity,
      color: podStatus.color.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        'Spojen: ${podStatus.name}',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  // --- GLAVNA LOGIKA ZA PRIKAZ SADRŽAJA ---
  Widget _buildPodContent(BuildContext context, PodStatus podStatus) {
    // Ovisno o ID-u spojenog POD-a, prikazujemo različito sučelje
    switch (podStatus.id) {
      case 1: // ID 1 = ECU POD (EB1)
        return _buildEcuPodLayout();
      // TODO: case 2: return _buildIbrPodLayout();
      // TODO: case 3: return _buildClusterPodLayout();
      default: // Ako nijedan POD nije spojen, prikaži poruku
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.usb_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'SDT POD nije spojen.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
    }
  }

  // --- KORISNIČKO SUČELJE ZA ECU POD (EB1) ---
  Widget _buildEcuPodLayout() {
    // Slušamo promjene na live podacima za ECU POD
    return ValueListenableBuilder<EcuPodData>(
      valueListenable: _sdmTService.ecuPodDataNotifier,
      builder: (context, data, child) {
        // ListView osigurava da možemo skrolati ako ima previše kartica
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNapajanjeCard(context, data),
            const SizedBox(height: 16),
            _buildStartSustavCard(context, data),
            const SizedBox(height: 16),
            _buildGorivoCard(context, data),
            const SizedBox(height: 16),
            _buildDessCard(context, data),
            const SizedBox(height: 16),
            _buildNtcCard(context, data),
            const SizedBox(height: 16),
            _buildCanCard(context, data),
            const SizedBox(height: 16),
            _buildTpsCard(context, data),
          ],
        );
      },
    );
  }

  // --- KARTICE ZA ECU POD ---

  Widget _buildNapajanjeCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Napajanje i Mase',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow('Pin H2 (+12V ECU):',
                '${data.pinH2Voltage.toStringAsFixed(2)} V'),
            _buildInfoRow('Pin M4 (+12V Kontakt):',
                '${data.pinM4Voltage.toStringAsFixed(2)} V'),
            // TODO: Gumb za slanje 12V
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusLight('L1', data.pinL1GndStatus),
                _buildStatusLight('M2', data.pinM2GndStatus),
                _buildStatusLight('M3', data.pinM3GndStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSustavCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Sustav', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Row(
              children: [
                _buildStatusLight('D1 Start Tipka', data.pinD1Continuity),
                const Spacer(),
                Text('Otpor: ${data.pinD1Resistance.toStringAsFixed(1)} Ω'),
              ],
            ),
            _buildStatusLight('L4 Start Relej', data.pinL4GndStatus),
            // TODO: Gumbi za slanje signala
          ],
        ),
      ),
    );
  }

  Widget _buildGorivoCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sustav Goriva',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildStatusLight('M1 Relej Pumpe', data.pinM1GndStatus),
            // TODO: Gumb za aktivaciju pumpe
          ],
        ),
      ),
    );
  }

  Widget _buildDessCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DESS Ključ', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildStatusLight('F2 Masa od ECU', data.pinF2GndStatus),
            // TODO: Gumb za slanje mase
          ],
        ),
      ),
    );
  }

  Widget _buildNtcCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NTC Senzori', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow(
                'EGTS (Otpor):', '${data.egtsResistance.toStringAsFixed(0)} Ω'),
            _buildInfoRow(
                'EGTS (Napon):', '${data.egtsVoltage.toStringAsFixed(2)} V'),
            const SizedBox(height: 8),
            _buildInfoRow(
                'LTS (Otpor):', '${data.ltsResistance.toStringAsFixed(0)} Ω'),
            _buildInfoRow(
                'LTS (Napon):', '${data.ltsVoltage.toStringAsFixed(2)} V'),
          ],
        ),
      ),
    );
  }

  Widget _buildCanCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CAN Sabirnica (Test Linije)',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow(
                'Otpor (C1-C2):', '${data.canResistance.toStringAsFixed(1)} Ω'),
            _buildInfoRow('CAN-H Napon (C1):',
                '${data.canHVoltage.toStringAsFixed(2)} V'),
            _buildInfoRow('CAN-L Napon (C2):',
                '${data.canLVoltage.toStringAsFixed(2)} V'),
          ],
        ),
      ),
    );
  }

  Widget _buildTpsCard(BuildContext context, EcuPodData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TPS Senzori (Hall x2)',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Text('TPS 1', style: Theme.of(context).textTheme.titleMedium),
            _buildInfoRow('  Napajanje (J3):',
                '${data.tps1Voltage5V.toStringAsFixed(2)} V'),
            _buildStatusLight('  Masa (B3)', data.tps1GndStatus),
            _buildInfoRow('  Signal (A3):',
                '${data.tps1SignalVoltage.toStringAsFixed(2)} V'),
            const SizedBox(height: 16),
            Text('TPS 2', style: Theme.of(context).textTheme.titleMedium),
            _buildInfoRow('  Napajanje (K1):',
                '${data.tps2Voltage5V.toStringAsFixed(2)} V'),
            _buildStatusLight('  Masa (K3)', data.tps2GndStatus),
            _buildInfoRow('  Signal (E1):',
                '${data.tps2SignalVoltage.toStringAsFixed(2)} V'),
          ],
        ),
      ),
    );
  }

  // --- POMOĆNI WIDGETI ZA ČISTIJI KOD ---

  // Pomoćni widget za prikaz retka s informacijom (npr. "Napon: 12.5V")
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
        ],
      ),
    );
  }

  // Pomoćni widget za prikaz statusne lampice (npr. za masu)
  Widget _buildStatusLight(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 16,
            color: isActive ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
