#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <Wire.h> // Dodajemo biblioteku za I2C

// --- I2C Postavke ---
#define PICO_I2C_ADDR 8 // I2C adresa Pico-a (MORA BITI ISTA KAO U PICO KODU)

// --- LED Pinovi ---
const int AP_LED_PIN = 13;
const int CLIENT_LED_PIN = 12;
const int CAN_LED_PIN = 14;

// --- Mrežne Postavke ---
const char* ssid = "SDT BOX";
const char* password = ""; 
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// --- Globalne varijable za stanje POD-a ---
int currentPodId = 0; 
String currentPodName = "Nije Uključeno";
unsigned long lastPodCheckTime = 0;
const int POD_CHECK_INTERVAL_MS = 1000; // Provjeravaj status svake sekunde

// --- Funkcija za provjeru statusa POD-a preko I2C ---
void checkPodStatus() {
  // Zatraži 1 bajt podataka od Pico-a na njegovoj I2C adresi
  Wire.requestFrom(PICO_I2C_ADDR, 1); 
  
  if (Wire.available()) {
    int newPodId = Wire.read(); // Pročitaj ID koji je poslao Pico
    
    // Ako se ID promijenio od zadnje provjere, ažuriraj stanje i javi aplikaciji
    if (newPodId != currentPodId) {
      currentPodId = newPodId;
      switch (currentPodId) {
        case 1: currentPodName = "ECU Pod (EB1)"; break; // Crveni Pod
        case 2: currentPodName = "iBR Pod"; break;
        case 3: currentPodName = "Cluster Pod"; break;
        // TODO: Dodati imena za ostale POD-ove
        default:
          currentPodId = 0;
          currentPodName = "Nije Uključeno";
          break;
      }
      
      Serial.printf("HARDVER DETEKCIJA: Spojen je novi POD -> ID: %d (%s)\n", currentPodId, currentPodName.c_str());

      // Kreiraj i pošalji status SVIM spojenim aplikacijama
      StaticJsonDocument<200> responseDoc;
      responseDoc["event"] = "pod_status_update";
      responseDoc["pod_id"] = currentPodId;
      responseDoc["pod_name"] = currentPodName;

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);
      ws.textAll(jsonResponse);
    }
  } else {
    // Ako Pico ne odgovara, znači da POD nije spojen ili postoji greška
    if (currentPodId != 0) {
      Serial.println("HARDVER DETEKCIJA: POD odspojen!");
      currentPodId = 0;
      currentPodName = "Nije Uključeno";

      // Javi aplikaciji da je POD odspojen
      StaticJsonDocument<200> responseDoc;
      responseDoc["event"] = "pod_status_update";
      responseDoc["pod_id"] = currentPodId;
      responseDoc["pod_name"] = currentPodName;

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);
      ws.textAll(jsonResponse);
    }
  }
}

// --- Funkcija za rukovanje WebSocket događajima ---
void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT: {
      Serial.printf("WebSocket klijent #%u spojen sa IP: %s\n", client->id(), client->remoteIP().toString().c_str());
      digitalWrite(CLIENT_LED_PIN, HIGH);
      
      // Odmah po spajanju, šaljemo trenutni status POD-a
      StaticJsonDocument<200> doc;
      doc["event"] = "pod_status_update";
      doc["pod_id"] = currentPodId;
      doc["pod_name"] = currentPodName;
      
      String jsonString;
      serializeJson(doc, jsonString);
      client->text(jsonString);
      break;
    }
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket klijent #%u odspojen\n", client->id());
      digitalWrite(CLIENT_LED_PIN, LOW);
      break;
    case WS_EVT_DATA: {
      AwsFrameInfo *info = (AwsFrameInfo*)arg;
      if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
        data[len] = 0;
        String message = (char*)data;
        Serial.printf("Primljena poruka od aplikacije: %s\n", message.c_str());

        // TODO: Ovdje ćemo parsirati naredbu i poslati je Pico-u preko I2C
      }
      break;
    }
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}

void setup() {
  Serial.begin(115200);

  // Postavljanje I2C kao Master
  // Standardni I2C pinovi za ESP32 su GPIO 21 (SDA) i GPIO 22 (SCL)
  Wire.begin(); 

  // Postavljanje LED pinova
  pinMode(AP_LED_PIN, OUTPUT);
  pinMode(CLIENT_LED_PIN, OUTPUT);
  pinMode(CAN_LED_PIN, OUTPUT);
  digitalWrite(AP_LED_PIN, LOW);
  digitalWrite(CLIENT_LED_PIN, LOW);
  digitalWrite(CAN_LED_PIN, LOW);

  // Postavljanje Wi-Fi Access Pointa
  WiFi.softAP(ssid, password);
  digitalWrite(AP_LED_PIN, HIGH);
  
  Serial.println("\nAP pokrenut.");
  Serial.print("SSID: ");
  Serial.println(ssid);
  Serial.print("IP adresa: ");
  Serial.println(WiFi.softAPIP());

  // Postavljanje WebSocket servera
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);

  // Pokretanje servera
  server.begin();
  Serial.println("WebSocket server pokrenut.");
}

void loop() {
  // Periodično provjeravaj status POD-a preko I2C
  if (millis() - lastPodCheckTime > POD_CHECK_INTERVAL_MS) {
    lastPodCheckTime = millis();
    checkPodStatus();
  }

  ws.cleanupClients();
  delay(10);
}

