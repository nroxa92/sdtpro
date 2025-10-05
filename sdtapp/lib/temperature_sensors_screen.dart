// lib/temperature_sensors_screen.dart - FINALNA REVIZIJA ZA LIVE V/A PODATKE
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';
import 'sensor_data.dart';
import 'websocket_service.dart';
import 'main_scaffold.dart'; // Dodajemo uvoz ako je bio potreban za AppBar

class TemperatureSensorsScreen extends StatefulWidget {
  final List<TemperatureSensorSpec> sensors;
  const TemperatureSensorsScreen({super.key, required this.sensors});

  @override
  State<TemperatureSensorsScreen> createState() =>
      _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  final SdmTService _sdmTService = SdmTService();

  TemperatureSensorSpec? _selectedSensor;

  final List<FlSpot> _voltageSpots = [];
  final List<FlSpot> _currentSpots = [];
  int _xValue = 0;
  final int _maxDataPoints = 50;

  // Uklonili smo Timer? _measurementTimer; jer C++ šalje podatke automatski

  @override
  void initState() {
    super.initState();
    _selectedSensor = widget.sensors.first;

    _initialResistanceMeasurement();
    // Pokretanje slušanja promjena za V/A graf
    _sdmTService.liveDataNotifier.addListener(_updateGraphData);

    // VAŽNO: Postavljamo početni cilj za C++ kod odmah pri ulasku na ekran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sdmTService.sendCommand('MEASURE_LIVE:${_selectedSensor!.id}');
    });
  }

  @override
  void dispose() {
    _sdmTService.liveDataNotifier.removeListener(_updateGraphData);
    super.dispose();
  }

  // --- LOGIKA ZA PODATKE ---

  void _initialResistanceMeasurement() {
    // *SIMULACIJA*: U stvarnosti, hardver bi poslao JSON sa svim otporima odjednom
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        for (var sensor in widget.sensors) {
          if (sensor.id == 'ECTS') {
            sensor.measuredResistance = 1750;
            sensor.status = 'ok';
          } else if (sensor.id == 'EGTS') {
            sensor.measuredResistance = 13000;
            sensor.status = 'error';
          } else {
            sensor.measuredResistance = 2500;
            sensor.status = 'ok';
          }
        }
      });
    });
  }

  void _updateGraphData() {
    if (!mounted) return;
    final liveData = _sdmTService.liveDataNotifier.value;

    setState(() {
      _voltageSpots.add(FlSpot(_xValue.toDouble(), liveData.measuredVoltage));
      _currentSpots.add(FlSpot(_xValue.toDouble(), liveData.measuredCurrent));

      if (_voltageSpots.length > _maxDataPoints) {
        _voltageSpots.removeAt(0);
        _currentSpots.removeAt(0);
      }
      _xValue++;
    });
  }

  // --- SIMBOLIKA STATUSA ---

  Widget _buildStatusSymbol(String status) {
    final Color color = switch (status) {
      'ok' => Colors.greenAccent,
      'error' => Colors.redAccent,
      _ => Colors.grey,
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.change_history, size: 24, color: color),
        Icon(
          status == 'ok'
              ? Icons.check
              : (status == 'error' ? Icons.close : Icons.circle),
          size: 10,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    );
  }

  // --- WIDGETI ZA PRIKAZ ---

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      // Koristimo AppBar koji se prosljeđuje MainScaffold-u
      appBar: AppBar(title: const Text('SENZORI TEMPERATURE (NTC)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResistanceTable(context),
            const SizedBox(height: 32),
            _buildLiveGraph(context),
            const SizedBox(height: 32),
            _buildReferenceInfo(context),
          ],
        ),
      ),
      title: '',
    );
  }

  Widget _buildResistanceTable(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Mjerenje Otpora i Pinout',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16.0,
              columns: const [
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('ECU Pinout')),
                DataColumn(
                    label: Text('Izmjereno (Ω)', textAlign: TextAlign.right),
                    numeric: true),
              ],
              rows: widget.sensors.map((sensor) {
                final isSelected = _selectedSensor == sensor;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (isSelected) {
                    if (isSelected ?? false) {
                      setState(() {
                        _selectedSensor = sensor;
                        _voltageSpots.clear(); // Resetiraj graf
                        _currentSpots.clear(); // Resetiraj graf
                        _xValue = 0;
                        // POPRAVAK: Slanje komande koju C++ sluša
                        _sdmTService
                            .sendCommand('MEASURE_LIVE:${_selectedSensor!.id}');
                      });
                    }
                  },
                  cells: [
                    DataCell(_buildStatusSymbol(sensor.status)),
                    DataCell(Text(sensor.id)),
                    DataCell(Text(sensor.ecuPinout,
                        style: const TextStyle(fontFamily: 'monospace'))),
                    DataCell(Text(
                        sensor.measuredResistance?.toStringAsFixed(0) ??
                            '---')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGraph(BuildContext context) {
    if (_selectedSensor == null) return const SizedBox.shrink();

    final maxVoltage = _voltageSpots.isNotEmpty
        ? _voltageSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
        : 5.0;
    final double maxCurrent = _currentSpots.isNotEmpty
        ? _currentSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
        : 2.0;
    final voltageRange = maxVoltage < 5.0 ? 5.0 : maxVoltage * 1.1;

    final adjustedVoltageSpots = _voltageSpots
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();
    final adjustedCurrentSpots = _currentSpots
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Mjerenje: ${_selectedSensor!.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<LiveData>(
              valueListenable: _sdmTService.liveDataNotifier,
              builder: (context, liveData, child) {
                return Text(
                  'Napon: ${liveData.measuredVoltage.toStringAsFixed(2)} V | Struja: ${liveData.measuredCurrent.toStringAsFixed(2)} A (Max A: ${maxCurrent.toStringAsFixed(2)})',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _maxDataPoints.toDouble() - 1,
                  minY: 0,
                  maxY: voltageRange.toDouble(),
                  gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1.0),
                  titlesData: const FlTitlesData(
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: Colors.white12)),
                  lineBarsData: [
                    // CRVENA - Struja (A)
                    LineChartBarData(
                      spots: adjustedCurrentSpots,
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // PLAVA - Napon (V)
                    LineChartBarData(
                      spots: adjustedVoltageSpots,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 10, height: 10, color: Colors.blueAccent),
                const SizedBox(width: 4),
                const Text('Napon (V)'),
                const SizedBox(width: 12),
                Container(width: 10, height: 10, color: Colors.redAccent),
                const SizedBox(width: 4),
                const Text('Struja (A)'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInfo(BuildContext context) {
    final referentniPodaci = referenceResistanceTable.entries
        .map((e) => '${e.key}°C: ${e.value} Ω')
        .join(' | ');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Referentna Tablica Otpora',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('Nominalni Otpor (20°C - 40°C):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(referentniPodaci),
          ],
        ),
      ),
    );
  }
}
