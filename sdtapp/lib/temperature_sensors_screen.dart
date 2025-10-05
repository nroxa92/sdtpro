import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';
import 'sensor_data.dart';
import 'websocket_service.dart';
import 'main_scaffold.dart';

class TemperatureSensorsScreen extends StatefulWidget {
  const TemperatureSensorsScreen({super.key, required this.sensors});

  final List<TemperatureSensorSpec> sensors;

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
  static const int _maxDataPoints = 50;

  @override
  void initState() {
    super.initState();
    if (widget.sensors.isNotEmpty) {
      _selectedSensor = widget.sensors.first;
    }

    _initialResistanceMeasurement();
    _sdmTService.liveDataNotifier.addListener(_updateGraphData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedSensor != null) {
        _sdmTService.sendCommand('MEASURE_LIVE:${_selectedSensor!.id}');
      }
    });
  }

  @override
  void dispose() {
    _sdmTService.liveDataNotifier.removeListener(_updateGraphData);
    super.dispose();
  }

  // --- LOGIKA ZA PODATKE (ostaje ista) ---
  void _initialResistanceMeasurement() {
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
    // Trokut (Status Boja je primarna)
    return Icon(Icons.change_history, size: 24, color: color);
  }

  // --- WIDGETI ZA PRIKAZ ---
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'SENZORI TEMPERATURE (NTC)',
      appBar: AppBar(title: const Text('SENZORI TEMPERATURE (NTC)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReferenceInfo(context),
            const SizedBox(height: 32),
            _buildResistanceTable(context),
            const SizedBox(height: 32),
            _buildLiveGraph(context),
          ],
        ),
      ),
    );
  }

  // NOVA METODA ZA RUKOVANJE KLIKOM (Da bude čisto i ponovljivo)
  void _handleRowTap(TemperatureSensorSpec sensor) {
    setState(() {
      _selectedSensor = sensor;
      _voltageSpots.clear();
      _currentSpots.clear();
      _xValue = 0;
      _sdmTService.sendCommand('MEASURE_LIVE:${_selectedSensor!.id}');
    });
  }

  Widget _buildResistanceTable(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mjerenje Otpora i Pinout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16.0,
              showCheckboxColumn: false, // OVO RJEŠAVA PROBLEM KVADRATIĆA!
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('ECU Pinout')),
                DataColumn(
                    label: Text('Izmjereno (Ω)', textAlign: TextAlign.right),
                    numeric: true),
              ],
              rows: widget.sensors.map((sensor) {
                final isSelected = _selectedSensor == sensor;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (isSelected) {
                      return Theme.of(context).primaryColor.withAlpha(75);
                    }
                    return null; // Koristi defaultnu boju
                  }),
                  onSelectChanged: (_) => _handleRowTap(sensor),
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
              'Mjerenje Napona/Struje: ${_selectedSensor!.name}',
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
            const Row(
              children: [
                SizedBox(
                    width: 10,
                    height: 10,
                    child: ColoredBox(color: Colors.blueAccent)),
                SizedBox(width: 4),
                Text('Napon (V)'),
                SizedBox(width: 12),
                SizedBox(
                    width: 10,
                    height: 10,
                    child: ColoredBox(color: Colors.redAccent)),
                SizedBox(width: 4),
                Text('Struja (A)'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInfo(BuildContext context) {
    final referentniRedovi = detailedResistanceTable.map((e) {
      final tolerance = e.high - e.nominal;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: 70,
                child: Text('${e.tempC}°C',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text('${e.nominal} Ω')),
            Text('+/- $tolerance Ω'),
          ],
        ),
      );
    }).toList();

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 70,
                        child: Icon(Icons.device_thermostat, size: 20)),
                    SizedBox(
                        width: 100,
                        child: Icon(Icons.settings_input_svideo, size: 20)),
                    Icon(Icons.compare_arrows, size: 20),
                  ]),
            ),
            const Divider(),
            ...referentniRedovi,
          ],
        ),
      ),
    );
  }
}
