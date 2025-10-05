import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Dodan import za 'Color'
import 'package:web_socket_channel/web_socket_channel.dart';
import 'models.dart';

// NOVO: Definicija modela za status POD-a.
// Kasnije ovo možete premjestiti u 'models.dart'.
class PodStatus {
  final int id;
  final String name;
  final Color color;

  PodStatus({
    this.id = 0,
    this.name = 'Nije Uključeno',
    this.color = Colors.grey,
  });

  // Tvornička metoda za kreiranje statusa iz ID-a
  factory PodStatus.fromId(int id) {
    switch (id) {
      case 1:
        return PodStatus(id: 1, name: 'ECU POD', color: Colors.blue);
      case 2:
        return PodStatus(id: 2, name: 'iBR POD', color: Colors.green);
      case 3:
        return PodStatus(id: 3, name: 'Cluster POD', color: Colors.yellow);
      default:
        return PodStatus(); // Vraća default status 'Nije Uključeno'
    }
  }
}

class SdmTService {
  static final SdmTService _instance = SdmTService._internal();
  factory SdmTService() => _instance;
  SdmTService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Postojeći Notifieri
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier(LiveData());
  final ValueNotifier<CanLiveData> canLiveDataNotifier =
      ValueNotifier(CanLiveData());
  final ValueNotifier<bool> canActivityNotifier = ValueNotifier(false);
  Timer? _canActivityTimer;

  // NOVO: Notifier za status POD-a
  final ValueNotifier<PodStatus> podStatusNotifier = ValueNotifier(PodStatus());

  Future<void> connect([String ipAddress = '192.168.4.1']) async {
    if (isConnectedNotifier.value) {
      if (kDebugMode) {
        debugPrint('WebSocket already connected.');
      }
      return;
    }
    try {
      final uri = Uri.parse(
          'ws://$ipAddress/ws'); // ISPRAVAK: Uklonjen port 81, Vi ga nemate u kodu
      _channel = WebSocketChannel.connect(uri);
      isConnectedNotifier.value = true;
      _subscription = _channel!.stream.listen(
        _onData,
        onDone: _handleDisconnect,
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          _handleDisconnect();
        },
      );
      if (kDebugMode) debugPrint('WebSocket connected to $ipAddress');
    } catch (e) {
      debugPrint('Connection failed: $e');
      _handleDisconnect();
    }
  }

  void _onData(dynamic data) {
    canActivityNotifier.value = true;
    _canActivityTimer?.cancel();
    _canActivityTimer = Timer(const Duration(milliseconds: 500), () {
      canActivityNotifier.value = false;
    });

    try {
      final jsonData = jsonDecode(data as String);
      final String dataType = jsonData['type'] as String? ?? '';

      // --- POČETAK NOVE LOGIKE ---
      if (dataType == 'pod_status_update') {
        final int podId = jsonData['pod_id'] as int? ?? 0;
        podStatusNotifier.value = PodStatus.fromId(podId);
        if (kDebugMode) {
          debugPrint(
              'Parsed pod_status_update (ID: ${podStatusNotifier.value.id}, Ime: ${podStatusNotifier.value.name})');
        }
      }
      // --- KRAJ NOVE LOGIKE ---

      else if (dataType == 'CAN_LIVE') {
        canLiveDataNotifier.value = CanLiveData.fromJson(jsonData);
        if (kDebugMode) {
          debugPrint('Parsed CAN_LIVE (RPM: ${canLiveDataNotifier.value.rpm})');
        }
      } else if (dataType == 'LIVE_MEASUREMENT') {
        liveDataNotifier.value = LiveData.fromJson(jsonData);
        if (kDebugMode) {
          debugPrint(
              'Parsed LIVE_MEASUREMENT (V: ${liveDataNotifier.value.measuredVoltage})');
        }
      }
    } catch (e) {
      debugPrint('Error parsing JSON data: $e');
    }
  }

  void sendCommand(String command) {
    if (isConnectedNotifier.value && _channel != null) {
      if (kDebugMode) debugPrint('WS SEND: $command');
      _channel!.sink.add(command);
    } else {
      if (kDebugMode) debugPrint('WS SEND FAILED: Not connected.');
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    isConnectedNotifier.value = false;
    canActivityNotifier.value = false;

    // NOVO: Resetiramo status poda na disconnect
    podStatusNotifier.value = PodStatus();

    liveDataNotifier.value = LiveData();
    canLiveDataNotifier.value = CanLiveData();
    if (kDebugMode) debugPrint('WebSocket disconnected.');
  }

  void disconnect() {
    _handleDisconnect();
  }
}
