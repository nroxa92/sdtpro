import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// ISPRAVAK: Import mora biti 'live_data.dart', a ne 'models.dart' za ovu klasu
import 'package:sdmt_final/models/live_data.dart';
import 'package:sdmt_final/services/websocket_service.dart';

class CanLiveScreen extends StatefulWidget {
  const CanLiveScreen({super.key});

  @override
  State<CanLiveScreen> createState() => _CanLiveScreenState();
}

class _CanLiveScreenState extends State<CanLiveScreen> {
  final sdmTService = SdmTService.instance;
  final Map<String, bool> _selectedParameters = {
    'RPM': true,
    'Gas': false,
    'Brzina': false,
  };
  final Map<String, Queue<FlSpot>> _chartData = {
    'RPM': Queue(),
    'Gas': Queue(),
    'Brzina': Queue(),
  };
  int _xValue = 0;
  final int _maxDataPoints = 50;

  @override
  void initState() {
    super.initState();
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
    _addSpot('Gas', data.throttle);
    _addSpot('Brzina', data.speed);

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
    return Scaffold(
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

  Widget _buildDataTable(LiveData data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Parametar')),
        DataColumn(label: Text('Vrijednost'), numeric: true),
        DataColumn(label: Text('Graf')),
      ],
      rows: _chartData.keys.map((key) {
        String value;
        switch(key) {
          case 'RPM': value = data.rpm.toStringAsFixed(0); break;
          case 'Gas': value = '${data.throttle.toStringAsFixed(1)} %'; break;
          case 'Brzina': value = '${data.speed.toStringAsFixed(1)} km/h'; break;
          default: value = 'N/A';
        }
        return DataRow(
          cells: [
            DataCell(Text(key)),
            DataCell(Text(value.contains("-1") ? "N/A" : value)),
            DataCell(Checkbox(
              value: _selectedParameters[key],
              onChanged: (bool? selected) {
                setState(() {
                  _selectedParameters[key] = selected ?? false;
                });
              },
            )),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChart() {
    final List<LineChartBarData> lineBarsData = [];
    final List<Color> colors = [Colors.cyan, Colors.lightGreenAccent, Colors.yellow];
    int colorIndex = 0;

    _selectedParameters.forEach((key, isSelected) {
      if (isSelected && _chartData[key]!.isNotEmpty) {
        lineBarsData.add(LineChartBarData(
          spots: _chartData[key]!.toList(),
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
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
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
            getDrawingVerticalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        ),
      ),
    );
  }
}