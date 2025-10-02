import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdmt_final/models/live_data.dart'; // <-- OVA LINIJA JE DODANA

class SdmTService {
  SdmTService._privateConstructor();
  static final SdmTService instance = SdmTService._privateConstructor();

  static const MethodChannel _channel = MethodChannel('com.sdtpro/network');

  WebSocketChannel? _webSocketChannel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier<LiveData>(LiveData.initial());
  final ValueNotifier<bool> canActivityNotifier = ValueNotifier<bool>(false);
  Timer? _canActivityTimer;

  Stream<String> get messages => _messageController.stream;

  Future<void> connect() async {
    if (isConnectedNotifier.value) {
      debugPrint("Već ste spojeni.");
      return;
    }
    
    try {
      await _channel.invokeMethod('bindToWiFi');
      debugPrint("Aplikacija uspješno zatražila vezanje za Wi-Fi mrežu.");
    } on PlatformException catch (e) {
      debugPrint("Greška pri pozivanju nativne metode: '${e.message}'.");
    }

    final wsUrl = Uri.parse('ws://192.168.4.1/ws');
    try {
      _webSocketChannel = WebSocketChannel.connect(wsUrl);
      isConnectedNotifier.value = true;
      debugPrint("WebSocket spojen.");

      _webSocketChannel!.stream.listen(
        _handleMessage,
        onDone: _handleDone,
        onError: (error) {
          debugPrint("WebSocket greška: $error");
          _handleDone();
        },
      );
    } catch (e) {
      isConnectedNotifier.value = false;
      debugPrint("Greška pri spajanju na WebSocket: $e");
    }
  }

  void _handleMessage(dynamic message) {
    _messageController.add(message.toString());
    try {
      final json = jsonDecode(message);
      if (json['rpm'] != null) {
        liveDataNotifier.value = LiveData.fromJson(json);
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

  void sendCommand(String command) {
    if (isConnectedNotifier.value) {
      _webSocketChannel?.sink.add(command);
    } else {
      debugPrint("Niste spojeni, ne mogu poslati naredbu.");
    }
  }

  void disconnect() {
    _webSocketChannel?.sink.close();
  }
}