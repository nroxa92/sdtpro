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

// --- GLOBALNE VARIJABLE ZA STANJE MJERENJA ---
// ID senzora kojeg aplikacija trenutno mjeri (npr. "ECTS", "EGTS")
String currentMeasureTarget = ""; 
// Brojač za simulaciju promjene podataka na V/A grafu
float mockDataCounter = 0.0; 

// --- STRUKTURA ZA LIVE CAN PODATKE (Usklađena s Flutter 'CanLiveData' modelom) ---
struct CanLiveData {
  float rpm = 0.0;
  float throttlePercent = 0.0;
  float coolantTemp = 0.0;
  float oilTemp = 0.0;
  float speedKmh = 0.0;
  float fuelLevel = 0.0;
  float mapKpa = 0.0;
  float intakeTemp = 0.0;
  float exhaustTemp = 0.0;
  float batteryVoltage = 12.5; 
  int gear = 0;
};
CanLiveData canLiveData;


// --- FUNKCIJA ZA RUKOVANJE DOLAZNIM KOMANDAMA IZ APP-a ---
void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.println("App povezan! Pokrecem slusanje...");
    digitalWrite(CLIENT_LED_PIN, HIGH); // Upali plavu LED
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.println("App odspojen.");
    digitalWrite(CLIENT_LED_PIN, LOW); // Ugasi plavu LED
    currentMeasureTarget = ""; // Resetiraj mjerenje pri prekidu veze
  } else if (type == WS_EVT_DATA) {
    // Primanje komande s aplikacije
    String incoming = (char*)data;
    Serial.print("WS REC: ");
    Serial.println(incoming);

    // Provjera komande za mjerenje V/A
    if (incoming.startsWith("MEASURE_LIVE:")) {
      currentMeasureTarget = incoming.substring(incoming.lastIndexOf(':') + 1);
      mockDataCounter = 0.0; // Resetiraj brojač za novi graf
      Serial.print("Postavljen cilj mjerenja: ");
      Serial.println(currentMeasureTarget);
    }
  }
}

// --- SIMULACIJA V/A MJERENJA ---
// U stvarnosti, ovdje bi se koristio ADS1115 i I2C za mjerenje!
void simulateVAMeasurement(float &voltage, float &current) {
  // Simulacija tipičnih vrijednosti za NTC senzor (npr. ECTS)
  if (currentMeasureTarget == "ECTS") {
    // Napon oko 2.5V, blaga fluktuacija
    voltage = 2.5 + (sin(mockDataCounter / 5.0) * 0.1); 
    // Struja niska (mA)
    current = 0.002 + (cos(mockDataCounter / 10.0) * 0.0005);
  } else if (currentMeasureTarget == "EGTS") {
    // Simulacija neispravnog senzora (nizak napon, visoka struja)
    voltage = 0.1 + (random(0, 10) / 100.0);
    current = 0.05 + (random(0, 10) / 1000.0);
  } else {
    voltage = 0.0;
    current = 0.0;
  }

  mockDataCounter += 1.0;
}


// --- DEKODIRANJE CAN PORUKA ---
// (Logika dekodiranja ostaje ista, jer radi!)
void decodeCanMessage(const CANMessage &inMessage) {
  digitalWrite(CAN_LED_PIN, HIGH);
  
  switch (inMessage.id) {
    case 0x0CF00400: // EEC1
      canLiveData.throttlePercent = inMessage.data[1] * 0.4;
      canLiveData.rpm = ((inMessage.data[4] * 256) + inMessage.data[3]) * 0.125;
      break;
    case 0x18FEEE00: // ET1
      canLiveData.coolantTemp = inMessage.data[0] - 40.0;
      canLiveData.oilTemp = (((inMessage.data[3] * 256.0) + inMessage.data[2]) * 0.03125) - 273.15;
      break;
    case 0x18FEF100: // CCVS1
      canLiveData.speedKmh = ((inMessage.data[1] * 256.0) + inMessage.data[0]) / 256.0; 
      break;
    case 0x18FEF200: // LFE
      canLiveData.fuelLevel = inMessage.data[1] * 0.4; 
      break;
    case 0x342: // Multipleksirano
      if (inMessage.data[0] == 0xAA) {
        canLiveData.mapKpa = ((inMessage.data[1] * 256.0) + inMessage.data[2]) * 0.41265 + 360.63; 
      } else if (inMessage.data[0] == 0xC1) {
        canLiveData.intakeTemp = 92.353 - (0.00113485 * ((inMessage.data[3] * 256.0) + inMessage.data[4])); 
      }
      break;
    case 0x103: 
      canLiveData.exhaustTemp = (inMessage.data[3] * 1.0125) - 60.0; 
      break;
  }
  
  delay(1); 
  digitalWrite(CAN_LED_PIN, LOW);
}


void setup() {
  Serial.begin(115200);
  pinMode(AP_LED_PIN, OUTPUT);
  pinMode(CLIENT_LED_PIN, OUTPUT);
  pinMode(CAN_LED_PIN, OUTPUT);
  digitalWrite(AP_LED_PIN, LOW);
  digitalWrite(CLIENT_LED_PIN, LOW);
  digitalWrite(CAN_LED_PIN, LOW);

  // --- CAN Setup ---
  ACAN_ESP32_Settings settings(500 * 1000);
  settings.mRxPin = GPIO_NUM_5;
  settings.mTxPin = GPIO_NUM_4;
  ACAN_ESP32::can.begin(settings);

  // --- Wi-Fi AP Setup ---
  WiFi.softAP(ssid, password);
  digitalWrite(AP_LED_PIN, HIGH);

  // --- WebServer Setup ---
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);
  server.begin();
  Serial.println("Server pokrenut. Cekam app...");
}


// --- LOOP PETLJA ---
unsigned long lastCanMessageTime = 0;
unsigned long lastVAMessageTime = 0;
const int CAN_MESSAGE_INTERVAL_MS = 250; // Slanje CAN dashboarda
const int VA_MESSAGE_INTERVAL_MS = 100;  // Slanje V/A grafa

void loop() {
  // 1. Primanje i dekodiranje CAN poruka
  CANMessage canMessage;
  if (ACAN_ESP32::can.receive(canMessage)) {
    decodeCanMessage(canMessage);
  }

  // 2. Periodično slanje CAN Live Dashboard poruke
  if (millis() - lastCanMessageTime > CAN_MESSAGE_INTERVAL_MS) {
    lastCanMessageTime = millis();
    
    StaticJsonDocument<512> doc;
    doc["type"] = "CAN_LIVE"; 
    doc["rpm"] = canLiveData.rpm;
    doc["throttlePercent"] = canLiveData.throttlePercent;
    doc["coolantTemp"] = canLiveData.coolantTemp;
    doc["oilTemp"] = canLiveData.oilTemp;
    doc["speedKmh"] = canLiveData.speedKmh;
    doc["fuelLevel"] = canLiveData.fuelLevel;
    doc["mapKpa"] = canLiveData.mapKpa;
    doc["intakeTemp"] = canLiveData.intakeTemp;
    doc["exhaustTemp"] = canLiveData.exhaustTemp;
    doc["batteryVoltage"] = canLiveData.batteryVoltage; 
    doc["gear"] = canLiveData.gear; 

    String jsonString;
    serializeJson(doc, jsonString);
    ws.textAll(jsonString);
  }
  
  // 3. Periodično slanje V/A Mjerenja (samo ako je senzor odabran)
  if (currentMeasureTarget != "" && millis() - lastVAMessageTime > VA_MESSAGE_INTERVAL_MS) {
    lastVAMessageTime = millis();
    
    float voltage, current;
    simulateVAMeasurement(voltage, current); // Simuliramo mjerenje
    
    StaticJsonDocument<256> vaDoc;
    vaDoc["type"] = "LIVE_MEASUREMENT"; // Ključ koji aplikacija čeka
    vaDoc["Voltage"] = voltage;
    vaDoc["Current"] = current;

    String vaJsonString;
    serializeJson(vaDoc, vaJsonString);
    ws.textAll(vaJsonString);
  }
  
  ws.cleanupClients();
  delay(1); 
}