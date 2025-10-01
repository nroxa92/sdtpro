#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <ACAN_ESP32.h>

// --- Mrežne Postavke ---
const char* ssid = "SeaDoo_Tool_AP";
const char* password = "pass1234";
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// --- Struktura za držanje svih Live Data vrijednosti ---
struct LiveData {
  float rpm = -1.0;
  float gas_postotak = -1.0;
  float ect_1 = -1.0; // Temp. rashladne tekućine iz ID 0x18FEEE00
  float eot_1 = -1.0; // Temp. ulja iz ID 0x18FEEE00
  float brzina_kmh = -1.0;
  float razina_goriva = -1.0;
  float map_hpa = -1.0;
  float ect_2 = -1.0; // Temp. rashladne tekućine iz ID 0x342
  float mat = -1.0;   // Temp. usisnog zraka
  float eot_2 = -1.0; // Temp. ulja iz ID 0x316
  float egt = -1.0;   // Temp. ispuha
};

LiveData liveData;

// --- WebSocket Handler ---
void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.printf("WebSocket klijent #%u spojen sa IP adrese: %s\n", client->id(), client->remoteIP().toString().c_str());
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.printf("WebSocket klijent #%u odspojen\n", client->id());
  }
}

// --- Funkcija za dekodiranje CAN poruka ---
void decodeCanMessage(const CANMessage &inMessage) {
  switch (inMessage.id) {
    case 0x0CF00400: // EEC1
      liveData.gas_postotak = inMessage.data[1] * 0.4;
      liveData.rpm = ((inMessage.data[4] * 256) + inMessage.data[3]) * 0.125;
      break;

    case 0x18FEEE00: // ET1
      liveData.ect_1 = inMessage.data[0] - 40;
      liveData.eot_1 = (((inMessage.data[3] * 256) + inMessage.data[2]) * 0.03125) - 273.15;
      break;

    case 0x18FEF100: // CCVS1
      liveData.brzina_kmh = ((inMessage.data[1] * 256) + inMessage.data[0]) / 256.0;
      break;

    case 0x18FEF200: // LFE
      liveData.razina_goriva = inMessage.data[1] * 0.4;
      break;

    case 0x342: // Multipleksirano
      if (inMessage.data[0] == 0xAA) {
        liveData.map_hpa = ((inMessage.data[2] * 256) + inMessage.data[3]) * 0.41265 + 360.63;
      } else if (inMessage.data[0] == 0xDE) {
        liveData.ect_2 = 56.9 - (0.0002455 * ((inMessage.data[2] * 256) + inMessage.data[3]));
      } else if (inMessage.data[0] == 0xC1) {
        liveData.mat = 92.353 - (0.00113485 * ((inMessage.data[4] * 256) + inMessage.data[5]));
      }
      break;

    case 0x316:
      liveData.eot_2 = (inMessage.data[3] * 0.943) - 17.2;
      break;

    case 0x103:
      liveData.egt = (inMessage.data[4] * 1.0125) - 60;
      // Gas (TPS/APS) ima kompleksniju formulu, za sada preskačemo
      break;
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("Booting SDmT Firmware...");

  // --- Postavljanje CAN-a ---
  // Koristimo pinove GPIO 5 (RX) i GPIO 4 (TX)
  ACAN_ESP32_Settings settings(500 * 1000); // Brzina 500 kbps
  settings.mRxPin = GPIO_NUM_5;
  settings.mTxPin = GPIO_NUM_4;
  const uint32_t errorCode = ACAN_ESP32::can.begin(settings);
  if (errorCode == 0) {
    Serial.println("CAN bus veza uspješna.");
  } else {
    Serial.printf("Greška pri spajanju na CAN bus: 0x%X\n", errorCode);
  }

  // --- Postavljanje Wi-Fi AP-a ---
  WiFi.softAP(ssid, password);
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);

  // --- Postavljanje WebServera i WebSocketa ---
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);
  server.begin();
  Serial.println("Server pokrenut.");
}

unsigned long lastMessageTime = 0;

void loop() {
  // 1. Provjeri ima li novih CAN poruka
  CANMessage canMessage;
  if (ACAN_ESP32::can.receive(canMessage)) {
    decodeCanMessage(canMessage);
  }

  // 2. Periodično (svakih 250ms) šalji SVE podatke preko WebSocketa
  if (millis() - lastMessageTime > 250) {
    lastMessageTime = millis();

    StaticJsonDocument<512> doc;
    doc["rpm"] = liveData.rpm;
    doc["throttle"] = liveData.gas_postotak;
    doc["ect"] = liveData.ect_1 > -1 ? liveData.ect_1 : liveData.ect_2; // Koristi ECT koji je dostupan
    doc["eot"] = liveData.eot_1 > -1 ? liveData.eot_1 : liveData.eot_2; // Koristi EOT koji je dostupan
    doc["speed"] = liveData.brzina_kmh;
    doc["fuel"] = liveData.razina_goriva;
    doc["map"] = liveData.map_hpa;
    doc["mat"] = liveData.mat;
    doc["egt"] = liveData.egt;

    String jsonString;
    serializeJson(doc, jsonString);
    ws.textAll(jsonString);
  }

  ws.cleanupClients();
}