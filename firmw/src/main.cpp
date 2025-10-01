#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>

// Ime i lozinka za Wi-Fi Access Point koji će ESP32 stvoriti
const char* ssid = "SeaDoo_Tool_AP";
const char* password = "password123";

// Kreiranje servera i WebSocket objekata
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// Funkcija koja se poziva kada se dogodi WebSocket event
void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.printf("WebSocket klijent #%u spojen sa IP adrese: %s\n", client->id(), client->remoteIP().toString().c_str());
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.printf("WebSocket klijent #%u odspojen\n", client->id());
  } else if (type == WS_EVT_DATA) {
    Serial.println("Primljeni podaci od klijenta, za sada ih ignoriramo.");
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("Booting...");

  // Postavljanje Wi-Fi AP-a
  WiFi.softAP(ssid, password);
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP); // Ovo bi trebalo ispisati 192.168.4.1

  // Povezivanje WebSocket handlera
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);

  // Dodavanje jednostavnog HTTP servera za testiranje veze iz browsera
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(200, "text/plain", "Pozdrav! HTTP server na ESP32 radi.");
  });

  // Pokretanje servera
  server.begin();
  Serial.println("Server pokrenut.");

  // OVDJE ĆE KASNIJE DOĆI KOD ZA INICIJALIZACIJU CAN-a
  // ACAN_ESP32_Settings settings (500 * 1000) ...
  // ACAN_ESP32::can.begin (settings) ...
}

unsigned long lastMessageTime = 0;

void loop() {
  ws.cleanupClients(); // Održavanje liste spojenih klijenata

  // Periodično slanje lažnih podataka (svake 2 sekunde)
  if (millis() - lastMessageTime > 2000) {
    lastMessageTime = millis();

    // Kreiranje JSON objekta
    StaticJsonDocument<100> doc;
    doc["millis"] = millis();
    doc["status"] = "Connected";
    
    String jsonString;
    serializeJson(doc, jsonString);

    // Slanje JSON-a svim spojenim klijentima
    ws.textAll(jsonString);
    Serial.print("Poslan JSON: ");
    Serial.println(jsonString);
  }

  // OVDJE ĆE KASNIJE DOĆI KOD ZA ČITANJE CAN PORUKA
  // if (ACAN_ESP32::can.receive (message)) { ... }
}