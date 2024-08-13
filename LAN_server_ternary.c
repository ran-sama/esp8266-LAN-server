extern "C" {
  #include "user_interface.h"
}

#include <FS.h>
#include <ESP8266WiFi.h>
#define BOARD_LED_PIN 2

WiFiServer server(8081);
const char *ssid = "name";
const char *password = "password";

void setup() {
  SPIFFS.begin();
  pinMode(BOARD_LED_PIN, OUTPUT);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  server.begin();
  server.setNoDelay(true);
  digitalWrite(BOARD_LED_PIN, HIGH);
}

void loop() {
  WiFiClient client = server.available();
  if(client.connected()) {
    unsigned int siz = 2412632; // please change according to your file
    digitalWrite(BOARD_LED_PIN, LOW);
    File webFile = SPIFFS.open("/index.html", "r");
    client.println("HTTP/1.1 200 OK");
    client.println("Connection: close");
    client.println("Content-Type: text/html");
    client.println("Content-Length: " + String(siz));
    client.println();
  
    char buf[2048];
    while(siz > 0) {
      size_t len = (int)(sizeof(buf) - 1) < siz ? (int)(sizeof(buf) - 1) : siz;
      webFile.read((uint8_t*) buf, len);
      client.write((const char*) buf, len);
      siz -= len;
    }
    client.stop();
    webFile.close();
    digitalWrite(BOARD_LED_PIN, HIGH);
    }
}
