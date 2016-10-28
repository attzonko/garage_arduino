// -*- c++ -*-
//
// Copyright 2010 Ovidiu Predescu <ovidiu@gmail.com>
// Date: December 2010
//

#include <SPI.h>
#include <Ethernet.h>
#include <Flash.h>
#include <SdFat.h>
#include <SdFatUtil.h>
#include <TinyWebServer.h>

// The LED attached in PIN 13 on an Arduino board.
const int buttonPin = 7;

boolean file_handler(TinyWebServer& web_server);
boolean press_button_handler(TinyWebServer& web_server);
boolean release_button_handler(TinyWebServer& web_server);
boolean index_handler(TinyWebServer& web_server);

TinyWebServer::PathHandler handlers[] = {
  {"/garage/", TinyWebServer::GET, &index_handler },
  {"/press_button", TinyWebServer::POST, &press_button_handler },
  {"/release_button", TinyWebServer::POST, &release_button_handler },
  {"/garage/" "*", TinyWebServer::GET, &file_handler },
  {NULL},
};

const char* headers[] = {
  "Content-Length",
  NULL
};

TinyWebServer web = TinyWebServer(handlers, headers);

boolean has_filesystem = true;
Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

static uint8_t mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x3D, 0x88 };

// Don't forget to modify the IP to an available one on your home network
byte ip[] = { 10, 0, 1, 2 };

void send_file_name(TinyWebServer& web_server, const char* filename) {
  if (!filename) {
    web_server.send_error_code(404);
    web_server << F("Could not parse URL");
  } else {
    TinyWebServer::MimeType mime_type
      = TinyWebServer::get_mime_type_from_filename(filename);
    web_server.send_error_code(200);
    web_server.send_content_type(mime_type);
    web_server.end_headers();
    if (file.open(&root, filename, O_READ)) {
      Serial << F("Read file "); Serial.println(filename);
      web_server.send_file(file);
      file.close();
    } else {
      web_server << F("Could not find file: ") << filename << "\n";
    }
  }
}

boolean file_handler(TinyWebServer& web_server) {
  char* filename = TinyWebServer::get_file_from_path(web_server.get_path());
  send_file_name(web_server, filename);
  free(filename);
  return true;
}

boolean press_button_handler(TinyWebServer& web_server) {
  web_server.send_error_code(200);
  web_server.send_content_type("text/plain");
  web_server.end_headers();

  // Pussh the button
  digitalWrite(buttonPin, HIGH);
}

boolean release_button_handler(TinyWebServer& web_server) {
  web_server.send_error_code(200);
  web_server.send_content_type("text/plain");
  web_server.end_headers();

  // Release the button
  digitalWrite(buttonPin, LOW);
}


boolean index_handler(TinyWebServer& web_server) {
  send_file_name(web_server, "INDEX.HTM");
  return true;
}

void setup() {
  Serial.begin(115200);
  Serial << F("Free RAM: ") << FreeRam() << "\n";

  pinMode(buttonPin, OUTPUT);

  // initialize the SD card
  Serial << F("Setting up SD card...\n");
  pinMode(10, OUTPUT); // set the SS pin as an output (necessary!)
  digitalWrite(10, HIGH); // but turn off the W5100 chip!
  if (!card.init(SPI_FULL_SPEED, 4)) {
    Serial << F("card failed\n");
    has_filesystem = false;
  }
  // initialize a FAT volume
  if (!volume.init(&card)) {
    Serial << F("vol.init failed!\n");
    has_filesystem = false;
  }
  if (!root.openRoot(&volume)) {
    Serial << F("openRoot failed");
    has_filesystem = false;
  }

  Serial << F("Setting up the Ethernet card...\n");
  Ethernet.begin(mac, ip);

  // Start the web server.
  Serial << F("Web server starting...\n");
  web.begin();

  Serial << F("Ready to accept HTTP requests.\n");
}

void loop() {
  if (has_filesystem) {
    web.process();
  }
}
