import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdmt_final/models/live_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SdmTService {
  SdmTService._privateConstructor();
  static final SdmTService instance = SdmTService._privateConstructor();

  static const MethodChannel _channel = MethodChannel('com.sdtpro/network');
  WebSocketChannel? _webSocketChannel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier<LiveData>(LiveData.initial());
  final ValueNotifier<bool> canActivityNotifier = ValueNotifier<bool>(false); // NOVO
  Timer? _canActivityTimer;

  Stream<String> get messages => _messageController.stream;

  Future<void> connect() async {
    // ...
  }
  
  void _handleMessage(dynamic message) {
    _messageController.add(message);
    try {
      final json = jsonDecode(message);
      if (json['rpm'] != null) {
        liveDataNotifier.value = LiveData.fromJson(json);
        // NOVO: Zabilježi CAN aktivnost i postavi tajmer da se ugasi
        canActivityNotifier.value = true;
        _canActivityTimer?.cancel();
        _canActivityTimer = Timer(const Duration(seconds: 2), () {
          canActivityNotifier.value = false;
        });
      }
    } catch(e) {
      debugPrint("Poruka nije LiveData JSON: $message");
    }
  }

  void _handleDone() {
    isConnectedNotifier.value = false;
    canActivityNotifier.value = false;
    liveDataNotifier.value = LiveData.initial();
    debugPrint("WebSocket konekcija zatvorena.");
  }
  
  // ... ostatak koda (disconnect, sendCommand) ostaje isti ...
}