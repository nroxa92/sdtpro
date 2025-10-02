#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <ACAN_ESP32.h>

// --- LED Pinovi ---
const int AP_LED_PIN = 13;      // Zelena LED za status AP-a
const int CLIENT_LED_PIN = 12;  // Plava LED za spojenu aplikaciju
const int CAN_LED_PIN = 14;     // Žuta LED za CAN aktivnost

// --- Mrežne Postavke ---
const char* ssid = "SeaDoo_Tool_AP";
const char* password = "";
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// ... (Struktura LiveData ostaje ista) ...
struct LiveData {
  float rpm = -1.0;
  float gas_postotak = -1.0;
  float ect_1 = -1.0;
  float eot_1 = -1.0;
  float brzina_kmh = -1.0;
  float razina_goriva = -1.0;
  float map_hpa = -1.0;
  float ect_2 = -1.0;
  float mat = -1.0;
  float eot_2 = -1.0;
  float egt = -1.0;
};
LiveData liveData;


void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.println("App povezan! Pokrecem slusanje, filtriranje i dekodiranje CAN paketa...");
    digitalWrite(CLIENT_LED_PIN, HIGH); // Upali plavu LED
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.println("App odspojen.");
    digitalWrite(CLIENT_LED_PIN, LOW); // Ugasi plavu LED
  }
}

// ... (Funkcija decodeCanMessage ostaje ista) ...
void decodeCanMessage(const CANMessage &inMessage) {
  // Treperenje žute LED-ice za svaku primljenu poruku
  digitalWrite(CAN_LED_PIN, HIGH);
  
  bool processed = false;
  switch (inMessage.id) {
    case 0x0CF00400:
      liveData.gas_postotak = inMessage.data[1] * 0.4;
      liveData.rpm = ((inMessage.data[4] * 256) + inMessage.data[3]) * 0.125;
      processed = true;
      break;
    case 0x18FEEE00:
      liveData.ect_1 = inMessage.data[0] - 40;
      liveData.eot_1 = (((inMessage.data[3] * 256) + inMessage.data[2]) * 0.03125) - 273.15;
      processed = true;
      break;
    // ... ostali case-ovi iz prethodnog koda ...
    case 0x18FEF100: liveData.brzina_kmh = ((inMessage.data[1] * 256) + inMessage.data[0]) / 256.0; processed = true; break;
    case 0x18FEF200: liveData.razina_goriva = inMessage.data[1] * 0.4; processed = true; break;
    case 0x342:
      if (inMessage.data[0] == 0xAA) { liveData.map_hpa = ((inMessage.data[2] * 256) + inMessage.data[3]) * 0.41265 + 360.63; processed = true; }
      else if (inMessage.data[0] == 0xDE) { liveData.ect_2 = 56.9 - (0.0002455 * ((inMessage.data[2] * 256) + inMessage.data[3])); processed = true; }
      else if (inMessage.data[0] == 0xC1) { liveData.mat = 92.353 - (0.00113485 * ((inMessage.data[4] * 256) + inMessage.data[5])); processed = true; }
      break;
    case 0x316: liveData.eot_2 = (inMessage.data[3] * 0.943) - 17.2; processed = true; break;
    case 0x103: liveData.egt = (inMessage.data[4] * 1.0125) - 60; processed = true; break;
  }

  if(processed) {
      Serial.printf("Nasao sam ID 0x%X, obradio i poslao u app.\n", inMessage.id);
  }
  
  // Kratki delay da se treptaj vidi
  delay(5); 
  digitalWrite(CAN_LED_PIN, LOW);
}


void setup() {
  Serial.begin(115200);
  Serial.println("\nESP pokrenut...");

  // Postavljanje LED pinova
  pinMode(AP_LED_PIN, OUTPUT);
  pinMode(CLIENT_LED_PIN, OUTPUT);
  pinMode(CAN_LED_PIN, OUTPUT);
  digitalWrite(AP_LED_PIN, LOW);
  digitalWrite(CLIENT_LED_PIN, LOW);
  digitalWrite(CAN_LED_PIN, LOW);

  // --- Postavljanje CAN-a ---
  ACAN_ESP32_Settings settings(500 * 1000);
  settings.mRxPin = GPIO_NUM_5;
  settings.mTxPin = GPIO_NUM_4;
  const uint32_t errorCode = ACAN_ESP32::can.begin(settings);
  if (errorCode == 0) {
    Serial.println("Uspjesno povezan CAN modul.");
  } else {
    Serial.printf("Greška pri spajanju na CAN modul: 0x%X\n", errorCode);
  }

  // --- Postavljanje Wi-Fi AP-a ---
  WiFi.softAP(ssid, password);
  IPAddress IP = WiFi.softAPIP();
  Serial.print("Uspjesno postavljen AP. IP adresa: ");
  Serial.println(IP);
  digitalWrite(AP_LED_PIN, HIGH); // Upali zelenu LED

  // --- Postavljanje WebServera i WebSocketa ---
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);
  server.begin();
  Serial.println("Server pokrenut. Cekam app...");
}

// ... (Loop funkcija ostaje ista) ...
unsigned long lastMessageTime = 0;
void loop() {
  CANMessage canMessage;
  if (ACAN_ESP32::can.receive(canMessage)) {
    decodeCanMessage(canMessage);
  }
  if (millis() - lastMessageTime > 250) {
    lastMessageTime = millis();
    StaticJsonDocument<512> doc;
    doc["rpm"] = liveData.rpm;
    doc["throttle"] = liveData.gas_postotak;
    doc["ect"] = liveData.ect_1 > -1 ? liveData.ect_1 : liveData.ect_2;
    doc["eot"] = liveData.eot_1 > -1 ? liveData.eot_1 : liveData.eot_2;
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