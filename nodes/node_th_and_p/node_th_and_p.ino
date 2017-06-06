
/*
* Getting Started example sketch for nRF24L01+ radios
* This is a very basic example of how to send data from one node to another
* Updated: Dec 2014 by TMRh20
*/

#include <SPI.h>
#include "RF24.h"

//const enum commands {pOn, pOff, getAirTH};
enum commands{pOn, pOff, getAirTH};

byte addresses[][6] = {"S1","N1"};

struct payload_request_t{
  char message[15];
};

struct payload_general_t{
  int command;
  int destination;
  char message[14];
};

payload_request_t outgoing;
payload_general_t incoming;

RF24 radio(7,8);

void setup() {
  Serial.begin(9600);
  Serial.println(F("Arduino start listening..."));

  radio.begin();

  // Set the PA Level low to prevent power supply related issues since this is a
 // getting_started sketch, and the likelihood of close proximity of the devices. RF24_PA_MAX is default.
  radio.setPALevel(RF24_PA_LOW);

  // Open a writing and reading pipe on each radio, with opposite addresses
  radio.openWritingPipe(addresses[1]);
  radio.openReadingPipe(1,addresses[0]);

  // Start the radio listening for data
  radio.startListening();
}

void loop() {
    unsigned long got_time;

    if( radio.available()){
                                                                    // Variable for the received timestamp
      while (radio.available()) {                                   // While there is data ready
        // get command data
        radio.read(&incoming, sizeof(payload_general_t));
      }

      if(incoming.command==pOn){
        Serial.print(F("Power on"));
      }else if(incoming.command==pOff){
        Serial.print(F("Power off\n"));
        Serial.print(F("Port: "));
        Serial.print(incoming.message);
        Serial.print(F("\n"));
      }else if(incoming.command==getAirTH){
        Serial.print(F("Air TH"));
      }

      if(incoming.destination==5){
        Serial.print(F("5 is received!"));  
      }

      radio.stopListening();                                        // First, stop listening so we can talk

      strcpy(outgoing.message, "OK");
      radio.write( &outgoing, sizeof(payload_request_t) );              // Send the final one back.
      radio.startListening();                                       // Now, resume listening so we catch the next packets.
      Serial.print(F("Sent response "));
      Serial.println(outgoing.message);
   }
} // Loop

