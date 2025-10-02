// lib/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart'; // Ispravan import na novi model

class SdmTService {
  // Singleton uzorak
  static final SdmTService _instance = SdmTService._internal();
  factory SdmTService() => _instance;
  SdmTService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier(LiveData());

  Future<void> connect(String ipAddress) async {
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
    try {
      final jsonData = jsonDecode(data as String);
      // Koristimo ispravan fromJson konstruktor iz novog LiveData modela
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
    // Resetira podatke na početne vrijednosti
    liveDataNotifier.value = LiveData(); 
  }
}