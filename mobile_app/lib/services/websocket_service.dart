import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SdmTService {
  // Singleton uzorak - osigurava da postoji samo jedna instanca ovog servisa
  SdmTService._privateConstructor();
  static final SdmTService instance = SdmTService._privateConstructor();

  WebSocketChannel? _channel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

  Stream<String> get messages => _messageController.stream;

  void connect() {
    if (isConnectedNotifier.value) {
      debugPrint("Već ste spojeni.");
      return;
    }
    
    final wsUrl = Uri.parse('ws://192.168.4.1/ws');
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      isConnectedNotifier.value = true;
      debugPrint("WebSocket spojen.");

      _channel!.stream.listen(
        (message) {
          _messageController.add(message);
        },
        onDone: () {
          isConnectedNotifier.value = false;
          debugPrint("WebSocket konekcija zatvorena.");
        },
        onError: (error) {
          isConnectedNotifier.value = false;
          debugPrint("WebSocket greška: $error");
        },
      );
    } catch (e) {
      isConnectedNotifier.value = false;
      debugPrint("Greška pri spajanju na WebSocket: $e");
    }
  }

  void sendCommand(String command) {
    if (isConnectedNotifier.value) {
      _channel?.sink.add(command);
    } else {
      debugPrint("Niste spojeni, ne mogu poslati naredbu.");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    isConnectedNotifier.value = false;
    debugPrint("Veza odspojena.");
  }
}