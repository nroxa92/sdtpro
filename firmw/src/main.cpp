#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>

// --- LED Pinovi (za buduću upotrebu) ---
const int AP_LED_PIN = 13;
const int CLIENT_LED_PIN = 12;
const int CAN_LED_PIN = 14;

// --- Mrežne Postavke ---
const char* ssid = "SDT BOX";
const char* password = ""; // Bez lozinke
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// --- Globalne varijable za stanje POD-a ---
int currentPodId = 0; // 0 = Nije spojen, 1 = ECU, 2 = iBR, 3 = Cluster
String currentPodName = "Nije Uključeno";

// --- Funkcija za rukovanje WebSocket događajima ---
void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT: {
      Serial.printf("WebSocket klijent #%u spojen sa IP: %s\n", client->id(), client->remoteIP().toString().c_str());
      digitalWrite(CLIENT_LED_PIN, HIGH); // VRAĆENO: Upali plavu LED
      
      // Odmah po spajanju, šaljemo trenutni status POD-a novom klijentu
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
      digitalWrite(CLIENT_LED_PIN, LOW); // VRAĆENO: Ugasi plavu LED
      break;
    case WS_EVT_DATA: {
      AwsFrameInfo *info = (AwsFrameInfo*)arg;
      if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
        data[len] = 0;
        String message = (char*)data;
        Serial.printf("Primljena poruka: %s\n", message.c_str());

        // Parsiranje JSON poruke
        StaticJsonDocument<200> doc;
        DeserializationError error = deserializeJson(doc, message);

        if (error) {
          Serial.print(F("deserializeJson() failed: "));
          Serial.println(error.f_str());
          return;
        }

        // Provjera naredbe za simulaciju
        const char* command = doc["command"];
        if (command && strcmp(command, "simulate_pod_connect") == 0) {
          int podIdToSimulate = doc["pod_id"];
          
          // Ažuriramo globalno stanje
          currentPodId = podIdToSimulate;
          switch (podIdToSimulate) {
            case 1: currentPodName = "ECU Connector"; break;
            case 2: currentPodName = "iBR Connector"; break;
            case 3: currentPodName = "Cluster Connector"; break;
            default:
              currentPodId = 0;
              currentPodName = "Nije Uključeno";
              break;
          }

          Serial.printf("SIMULACIJA: Spojen POD ID %d (%s)\n", currentPodId, currentPodName.c_str());

          // Kreiramo i šaljemo status SVIM spojenim klijentima
          StaticJsonDocument<200> responseDoc;
          responseDoc["event"] = "pod_status_update";
          responseDoc["pod_id"] = currentPodId;
          responseDoc["pod_name"] = currentPodName;

          String jsonResponse;
          serializeJson(responseDoc, jsonResponse);
          ws.textAll(jsonResponse); // textAll šalje svima
        }
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

  // --- VRAĆENO: Postavljanje LED pinova ---
  pinMode(AP_LED_PIN, OUTPUT);
  pinMode(CLIENT_LED_PIN, OUTPUT);
  pinMode(CAN_LED_PIN, OUTPUT);
  digitalWrite(AP_LED_PIN, LOW);
  digitalWrite(CLIENT_LED_PIN, LOW);
  digitalWrite(CAN_LED_PIN, LOW);

  // Postavljanje Wi-Fi Access Pointa
  WiFi.softAP(ssid, password);
  digitalWrite(AP_LED_PIN, HIGH); // VRAĆENO: Upali zelenu LED kad je AP spreman
  
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
  Serial.println("WebSocket server pokrenut. Čekam klijente...");
}

void loop() {
  ws.cleanupClients();
  delay(10);
}

