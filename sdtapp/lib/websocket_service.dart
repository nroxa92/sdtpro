import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Uvozimo SVE naše modele iz jedne centralne datoteke
import 'models.dart';

class SdmTService {
  static final SdmTService _instance = SdmTService._internal();
  factory SdmTService() => _instance;
  SdmTService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // --- Postojeći Notifieri ---
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<LiveData> liveDataNotifier = ValueNotifier(LiveData());
  final ValueNotifier<CanLiveData> canLiveDataNotifier =
      ValueNotifier(CanLiveData());
  final ValueNotifier<bool> canActivityNotifier = ValueNotifier(false);
  Timer? _canActivityTimer;

  // --- Notifieri za specifične POD-ove ---
  final ValueNotifier<PodStatus> podStatusNotifier = ValueNotifier(PodStatus());

  // NOVO: Notifier koji će čuvati sve live podatke za ECU POD
  final ValueNotifier<EcuPodData> ecuPodDataNotifier =
      ValueNotifier(EcuPodData());

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
    canActivityNotifier.value = true;
    _canActivityTimer?.cancel();
    _canActivityTimer = Timer(const Duration(milliseconds: 500), () {
      canActivityNotifier.value = false;
    });

    try {
      final jsonData = jsonDecode(data as String);

      // Prvo provjeravamo je li poruka za status POD-a
      final String eventType = jsonData['event'] as String? ?? '';
      if (eventType == 'pod_status_update') {
        final int podId = jsonData['pod_id'] as int? ?? 0;
        final String podName =
            jsonData['pod_name'] as String? ?? 'Nije Uključeno';

        // Kreiramo novi status objekt s odgovarajućom bojom
        Color color = switch (podId) {
          1 => Colors.red,
          2 => Colors.green,
          3 => Colors.yellow,
          _ => Colors.grey,
        };
        podStatusNotifier.value =
            PodStatus(id: podId, name: podName, color: color);

        if (kDebugMode) {
          debugPrint(
              'Ažuriran status POD-a (ID: ${podStatusNotifier.value.id})');
        }
      } else {
        // Ako nije status, provjeravamo je li za live podatke
        final String dataType = jsonData['type'] as String? ?? '';

        if (dataType == 'ECU_POD_DATA') {
          // NOVO: Parsiramo i spremamo live podatke za ECU POD
          ecuPodDataNotifier.value = EcuPodData.fromJson(jsonData);
          if (kDebugMode) {
            debugPrint(
                'Primljeni ECU POD podaci (Napon H2: ${ecuPodDataNotifier.value.pinH2Voltage}V)');
          }
        } else if (dataType == 'CAN_LIVE') {
          canLiveDataNotifier.value = CanLiveData.fromJson(jsonData);
        } else if (dataType == 'LIVE_MEASUREMENT') {
          liveDataNotifier.value = LiveData.fromJson(jsonData);
        }
      }
    } catch (e) {
      debugPrint('Error parsing JSON data: $e');
    }
  }

  void sendCommand(String command) {
    if (isConnectedNotifier.value && _channel != null) {
      if (kDebugMode) debugPrint('WS SEND: $command');
      // Šaljemo JSON formatiranu poruku
      final commandJson = jsonEncode({'command': command});
      _channel!.sink.add(commandJson);
    } else {
      if (kDebugMode) debugPrint('WS SEND FAILED: Not connected.');
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    isConnectedNotifier.value = false;
    canActivityNotifier.value = false;

    // Resetiramo sve statuse na početne vrijednosti
    podStatusNotifier.value = PodStatus();
    ecuPodDataNotifier.value = EcuPodData(); // NOVO: Resetiramo i ECU podatke
    liveDataNotifier.value = LiveData();
    canLiveDataNotifier.value = CanLiveData();
    if (kDebugMode) debugPrint('WebSocket disconnected.');
  }

  void disconnect() {
    _handleDisconnect();
  }
}
