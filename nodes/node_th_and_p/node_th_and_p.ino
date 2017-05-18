
/*
* Getting Started example sketch for nRF24L01+ radios
* This is a very basic example of how to send data from one node to another
* Updated: Dec 2014 by TMRh20
*/

#include <SPI.h>
#include "RF24.h"

const enum commands {pOn, pOff, getAirTH};

struct payload_request_t{
  char message[15];
};

struct payload_general_t{
  enum command;
  int destination;
  char message[14];
};

payload_request_t outgoing;
payload_general_t incoming;

RF24 radio(7,8);

void setup() {
  Serial.begin(115200);
  Serial.println(F("Arduino start listening..."));

  radio.begin();

  // Set the PA Level low to prevent power supply related issues since this is a
 // getting_started sketch, and the likelihood of close proximity of the devices. RF24_PA_MAX is default.
  radio.setPALevel(RF24_PA_LOW);

  // Open a writing and reading pipe on each radio, with opposite addresses
  radio.openWritingPipe("Node1");
  radio.openReadingPipe(1,"Server1");

  // Start the radio listening for data
  radio.startListening();
}

void loop() {
/****************** Pong Back Role ***************************/

    unsigned long got_time;

    if( radio.available()){
                                                                    // Variable for the received timestamp
      while (radio.available()) {                                   // While there is data ready
        // get command data
        radio.read(&incoming, sizeof(payload_general_t));
      }

      if(data.command==pOn){
        Serial.print(F("Power on"));
      }elsif(data.command==pOff){
        Serial.print(F("Power off"));
      }elsif(data.command==getAirTH){
        Serial.print(F("Air TH"));
      }

      radio.stopListening();                                        // First, stop listening so we can talk
      outgoing.message = "OK";
      radio.write( &outgoing, sizeof(payload_request_t) );              // Send the final one back.
      radio.startListening();                                       // Now, resume listening so we catch the next packets.
      Serial.print(F("Sent response "));
      Serial.println(outgoing.message);
   }
} // Loop

