// lib/services/websocket_service.dart

import 'dart.async';
import 'dart.convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

class SdmTService {
  static final SdmTService _instance = SdmTService._internal();
  factory SdmTService() => _instance;
  SdmTService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier(LiveData());
  // VRAĆAMO NOTIFIER ZA CAN AKTIVNOST KOJI JE NEDOSTAJAO
  final ValueNotifier<bool> canActivityNotifier = ValueNotifier(false); 
  Timer? _canActivityTimer;

  // ISPRAVAK: Metoda connect sada ima opcionalni argument s defaultnom IP adresom
  Future<void> connect([String ipAddress = '192.168.4.1']) async {
    if (isConnectedNotifier.value) {
      disconnect();
    }
    try {
      final uri = Uri.parse('ws://$ipAddress/ws');
      _channel = WebSocketChannel.connect(uri);
      isConnectedNotifier.value = true;

      _subscription = _channel!.stream.listen(
        _onData,
        onDone: disconnect,
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          disconnect();
        },
      );
    } catch (e) {
      debugPrint('Connection failed: $e');
      isConnectedNotifier.value = false;
    }
  }

  void _onData(dynamic data) {
    // Svaki put kad stignu podaci, znamo da je CAN aktivan
    canActivityNotifier.value = true;
    _canActivityTimer?.cancel();
    _canActivityTimer = Timer(const Duration(milliseconds: 500), () {
      canActivityNotifier.value = false; // Ugasimo status ako nema podataka pola sekunde
    });

    try {
      final jsonData = jsonDecode(data as String);
      liveDataNotifier.value = LiveData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error parsing JSON data: $e');
    }
  }

  void sendCommand(String command) {
    if (isConnectedNotifier.value && _channel != null) {
      _channel!.sink.add(command);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    isConnectedNotifier.value = false;
    canActivityNotifier.value = false;
    liveDataNotifier.value = LiveData();
  }
}