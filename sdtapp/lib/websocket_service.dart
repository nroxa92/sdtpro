// lib/services/websocket_service.dart - KONAČNI POPRAVAK
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// VRLO VAŽNO: Osiguravamo da je uvoz models.dart točan!
import 'models.dart';

class SdmTService {
  static final SdmTService _instance = SdmTService._internal();
  factory SdmTService() => _instance;
  SdmTService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier(LiveData());

  // Riješena greška: CanLiveData sada je ispravno prepoznata kao tip
  final ValueNotifier<CanLiveData> canLiveDataNotifier =
      ValueNotifier(CanLiveData());

  final ValueNotifier<bool> canActivityNotifier = ValueNotifier(false);
  Timer? _canActivityTimer;

  Future<void> connect([String ipAddress = '192.168.4.1']) async {
    if (isConnectedNotifier.value) {
      if (kDebugMode) {
        debugPrint('WebSocket already connected.');
      }
      return;
    }

    try {
      final uri = Uri.parse('ws://$ipAddress/ws');
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
    // Ažuriramo status CAN aktivnosti
    canActivityNotifier.value = true;
    _canActivityTimer?.cancel();
    _canActivityTimer = Timer(const Duration(milliseconds: 500), () {
      canActivityNotifier.value = false;
    });

    try {
      final jsonData = jsonDecode(data as String);

      final String dataType = jsonData['type'] as String? ?? '';

      // Riješena stilska greška: Dodane vitičaste zagrade {}
      if (dataType == 'CAN_LIVE') {
        canLiveDataNotifier.value = CanLiveData.fromJson(jsonData);
        if (kDebugMode) {
          debugPrint('Parsed CAN_LIVE (RPM: ${canLiveDataNotifier.value.rpm})');
        }
      }

      // Riješena stilska greška: Dodane vitičaste zagrade {}
      if (dataType == 'LIVE_MEASUREMENT') {
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

    liveDataNotifier.value = LiveData();
    canLiveDataNotifier.value = CanLiveData();
    if (kDebugMode) debugPrint('WebSocket disconnected.');
  }

  void disconnect() {
    _handleDisconnect();
  }
}
