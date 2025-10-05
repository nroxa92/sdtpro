#include <Arduino.h>
#include <Wire.h> // Uključujemo biblioteku za I2C komunikaciju

// --- I2C Adrese ---
#define PICO_I2C_ADDR 8      // Adresa na kojoj će se Pico javljati ESP32
#define EEPROM_I2C_ADDR 0x50 // Standardna adresa za AT24Cxx EEPROM-e

// Globalna varijabla za spremanje pročitanog ID-a POD-a
byte podId = 0; // 0 = Nije spojen ili greška

// --- Funkcija koja se poziva kada Master (ESP32) zatraži podatke ---
void requestEvent() {
  Wire.write(podId); // Pošalji trenutno pohranjeni ID natrag Masteru
  Serial.print("ESP32 je zatražio podatke. Poslao sam ID: ");
  Serial.println(podId);
}

// --- Funkcija za čitanje ID-a s EEPROM čipa ---
byte readPodIdFromEeprom() {
  // Započinjemo prijenos prema EEPROM-u
  Wire.beginTransmission(EEPROM_I2C_ADDR);
  Wire.write(0); // Postavljamo pointer na memorijsku adresu 0
  byte error = Wire.endTransmission(false); 

  if (error != 0) {
    Serial.println("Greška: EEPROM nije pronađen na I2C adresi!");
    return 0;
  }

  // Zatražimo 1 bajt podataka s trenutne adrese (0)
  Wire.requestFrom(EEPROM_I2C_ADDR, 1);

  if (Wire.available()) {
    return Wire.read(); // Pročitaj i vrati bajt (naš ID)
  }

  return 0;
}


void setup() {
  Serial.begin(115200);
  delay(2000); // Duža pauza da se sigurno stigne pokrenuti Serial monitor
  Serial.println("\nPico Firmware Pokrenut");

  // Inicijalizacija I2C sabirnice.
  // Za Arduino-Mbed core na Pico-u, ovo automatski postavlja
  // zadane pinove (GP4 za SDA, GP5 za SCL).
  // Ne koristimo setSDA() i setSCL() jer nisu podržani.
  Wire.begin(); 
  delay(100);
  // Pročitaj ID s EEPROM-a dok je Pico u Master modu
  podId = readPodIdFromEeprom();
  Serial.print("Pročitani ID s EEPROM-a: ");
  Serial.println(podId);

  // Završi Master mod prije prebacivanja u Slave
  Wire.end();

  // Prebacivanje u I2C Slave mod da sluša ESP32.
  // Re-inicijaliziramo 'Wire' objekt na našoj adresi kao Slave.
  Wire.begin(PICO_I2C_ADDR); 
  Wire.onRequest(requestEvent); // Registriraj funkciju koja se poziva na zahtjev
  
  Serial.print("Pico je postavljen kao I2C Slave na adresi: ");
  Serial.println(PICO_I2C_ADDR);
}

void loop() {
  // Glavna petlja je za sada prazna. Pico samo čeka na I2C zahtjeve.
  delay(100);
}

