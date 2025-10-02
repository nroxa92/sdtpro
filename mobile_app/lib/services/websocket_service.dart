import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Važan import za MethodChannel
import 'package:sdmt_final/models/live_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SdmTService {
  // Singleton uzorak
  SdmTService._privateConstructor();
  static final SdmTService instance = SdmTService._privateConstructor();

  // Kanal za komunikaciju s nativnim Android kodom
  static const MethodChannel _channel = MethodChannel('com.sdtpro/network');

  WebSocketChannel? _webSocketChannel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier<LiveData>(LiveData.initial());

  Stream<String> get messages => _messageController.stream;

  // Funkcija je sada 'async' jer čeka odgovor od nativnog koda
  Future<void> connect() async {
    if (isConnectedNotifier.value) {
      debugPrint("Već ste spojeni.");
      return;
    }

    // Pokušaj vezanja aplikacije za Wi-Fi mrežu prije spajanja
    try {
      final bool bound = await _channel.invokeMethod('bindToWiFi');
      if (bound) {
        debugPrint("Aplikacija uspješno zatražila vezanje za Wi-Fi mrežu.");
      } else {
        debugPrint("Nije uspjelo zatražiti vezivanje za Wi-Fi mrežu.");
      }
    } on PlatformException catch (e) {
      debugPrint("Greška pri pozivanju nativne metode: '${e.message}'.");
    }

    // Nastavak spajanja na WebSocket
    final wsUrl = Uri.parse('ws://192.168.4.1/ws');
    try {
      _webSocketChannel = WebSocketChannel.connect(wsUrl);
      isConnectedNotifier.value = true;
      debugPrint("WebSocket spojen.");

      _webSocketChannel!.stream.listen(
        (message) {
          _messageController.add(message);

          try {
            final json = jsonDecode(message);
            if (json['rpm'] != null) {
              liveDataNotifier.value = LiveData.fromJson(json);
            }
          } catch(e) {
            debugPrint("Poruka nije LiveData JSON: $message");
          }
        },
        onDone: () {
          isConnectedNotifier.value = false;
          liveDataNotifier.value = LiveData.initial();
          debugPrint("WebSocket konekcija zatvorena.");
        },
        onError: (error) {
          isConnectedNotifier.value = false;
          liveDataNotifier.value = LiveData.initial();
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
      _webSocketChannel?.sink.add(command);
    } else {
      debugPrint("Niste spojeni, ne mogu poslati naredbu.");
    }
  }

  void disconnect() {
    _webSocketChannel?.sink.close();
  }
}