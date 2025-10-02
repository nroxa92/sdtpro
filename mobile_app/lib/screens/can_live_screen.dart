import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/services/websocket_service.dart';
import 'package:sdmt_final/widgets/main_scaffold.dart';

class CanLiveScreen extends StatefulWidget {
  const CanLiveScreen({super.key});
  @override
  State<CanLiveScreen> createState() => _CanLiveScreenState();
}

class _CanLiveScreenState extends State<CanLiveScreen> {
  late final SdmTService sdmTService;

  final Map<String, bool> _selectedParameters = {
    'RPM': true, 'TPS': false, 'Brzina': false, 'Gorivo': false,
    'ECT': false, 'EOT': false, 'MAT': false, 'EGT': false, 'MAP': false,
  };
  final Map<String, Queue<FlSpot>> _chartData = {
    'RPM': Queue(), 'TPS': Queue(), 'Brzina': Queue(), 'Gorivo': Queue(),
    'ECT': Queue(), 'EOT': Queue(), 'MAT': Queue(), 'EGT': Queue(), 'MAP': Queue(),
  };
  
  int _xValue = 0;
  final int _maxDataPoints = 50;

  @override
  void initState() {
    super.initState();
    sdmTService = SdmTService.instance;
    sdmTService.liveDataNotifier.addListener(_updateChartData);
  }

  @override
  void dispose() {
    sdmTService.liveDataNotifier.removeListener(_updateChartData);
    super.dispose();
  }

  void _updateChartData() {
    final data = sdmTService.liveDataNotifier.value;
    
    _addSpot('RPM', data.rpm);
    _addSpot('TPS', data.throttle);
    _addSpot('Brzina', data.speed);
    _addSpot('Gorivo', data.fuel);
    _addSpot('ECT', data.ect);
    _addSpot('EOT', data.eot);
    _addSpot('MAT', data.mat);
    _addSpot('EGT', data.egt);
    _addSpot('MAP', data.map);

    _xValue++;
    if(mounted) setState(() {});
  }

  void _addSpot(String key, double y) {
    if(y < 0) return;
    final queue = _chartData[key]!;
    if (queue.length >= _maxDataPoints) {
      queue.removeFirst();
    }
    queue.add(FlSpot(_xValue.toDouble(), y));
  }

  @override
  Widget build(BuildContext context) {
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

  DataTable _buildDataTable(LiveData data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Parametar')),
        DataColumn(label: Text('Vrijednost'), numeric: true),
        DataColumn(label: Text('Graf')),
      ],
      rows: [
        _buildDataRow('RPM', data.rpm.toStringAsFixed(0), ''),
        _buildDataRow('TPS', data.throttle.toStringAsFixed(1), '%'),
        _buildDataRow('Brzina', data.speed.toStringAsFixed(1), 'km/h'),
        _buildDataRow('Gorivo', data.fuel.toStringAsFixed(1), '%'),
        _buildDataRow('ECT', data.ect.toStringAsFixed(1), '°C'),
        _buildDataRow('EOT', data.eot.toStringAsFixed(1), '°C'),
        _buildDataRow('MAT', data.mat.toStringAsFixed(1), '°C'),
        _buildDataRow('EGT', data.egt.toStringAsFixed(1), '°C'),
        _buildDataRow('MAP', data.map.toStringAsFixed(1), 'hPa'),
      ],
    );
  }

  DataRow _buildDataRow(String key, String value, String unit) {
    final displayValue = value.contains("-1") ? "N/A" : '$value $unit';
    return DataRow(
      cells: [
        DataCell(Text(key)),
        DataCell(Text(displayValue)),
        DataCell(Checkbox(
          value: _selectedParameters[key],
          onChanged: (bool? selected) {
            setState(() { _selectedParameters[key] = selected ?? false; });
          },
        )),
      ],
    );
  }

  Widget _buildChart() {
    final List<LineChartBarData> lineBarsData = [];
    final List<Color> colors = [Colors.cyan, Colors.lightGreenAccent, Colors.yellow, Colors.redAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.white, Colors.pink];
    int colorIndex = 0;

    _selectedParameters.forEach((key, isSelected) {
      if (isSelected && _chartData[key]!.isNotEmpty) {
        lineBarsData.add(LineChartBarData(
          spots: _chartData[key]!.toList(),
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ));
        colorIndex++;
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: lineBarsData,
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
            getDrawingVerticalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        ),
      ),
    );
  }
}