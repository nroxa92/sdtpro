import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sdmt_final/models/live_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SdmTService {
  SdmTService._privateConstructor();
  static final SdmTService instance = SdmTService._privateConstructor();

  WebSocketChannel? _channel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);
  
  // NOVO: Notifier koji drži zadnje stanje živih podataka
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier<LiveData>(LiveData.initial());

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

          // NOVO: Pokušaj parsiranja poruke kao LiveData JSON
          try {
            final json = jsonDecode(message);
            // Provjeravamo ima li ključ 'rpm' da znamo da je to LiveData poruka
            if (json['rpm'] != null) {
              liveDataNotifier.value = LiveData.fromJson(json);
            }
          } catch(e) {
            debugPrint("Poruka nije LiveData JSON: $message");
          }
        },
        onDone: () {
          isConnectedNotifier.value = false;
          liveDataNotifier.value = LiveData.initial(); // Resetiraj podatke
          debugPrint("WebSocket konekcija zatvorena.");
        },
        onError: (error) {
          isConnectedNotifier.value = false;
          liveDataNotifier.value = LiveData.initial(); // Resetiraj podatke
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
  }
}