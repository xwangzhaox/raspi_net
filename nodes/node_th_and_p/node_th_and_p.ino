
/*
* Getting Started example sketch for nRF24L01+ radios
* This is a very basic example of how to send data from one node to another
* Updated: Dec 2014 by TMRh20
*/

#include <SPI.h>
#include "RF24.h"
#include "stdlib.h"
#include "DHT.h"

enum commands{pOn, pOff, getAirTH};

byte addresses[][6] = {"S1","N3"};
char seps[]   = "_";
char *command;

struct payload_request_t{
  char message[15];
};

struct payload_general_t{
//  int command;
//  int destination;
  char message[14];
};

payload_request_t outgoing;
payload_general_t incoming;

RF24 radio(9,10);

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


//      if(incoming.command==pOn){
//        Serial.print(F("Power on"));
//      }else if(incoming.command==pOff){
//        Serial.print(F("Power off\n"));
//        Serial.print(F("Port: "));
//        Serial.print(incoming.message);
//        Serial.print(F("\n"));
//      }else if(incoming.command==getAirTH){
//        Serial.print(F("Air TH"));
//      }

//      command = strtok( incoming.message, seps );
//      while(command !=NULL)
//      {
//        Serial.print(command);
//        Serial.print(F("\n"));
//        command=strtok(NULL,seps);
//      }
Serial.print(F("Message: "));
Serial.print(incoming.message);
        Serial.print(F("\n"));
      char dst[3][3];
      int cnt = split(dst, incoming.message, "_");
      if(strcmp(&dst[0][0],"p")==0){
        Serial.print(F("PUT "));
        Serial.print(dst[2]);
        int pin = atoi(dst[2]);
        pinMode(pin,OUTPUT);
        if(strcmp(* &dst[1],"on")==0){
          Serial.print(F(" ON."));
          digitalWrite(pin, HIGH);
        }else{
          Serial.print(F(" OFF"));
          digitalWrite(pin, LOW);
        }
        delay(1000);
        Serial.print(F("\n"));
        strcpy(outgoing.message, "OK");
      }else if (strcmp(&dst[0][0],"g")==0){
        if(strcmp(* &dst[1],"th")==0){
          Serial.print(F("return th: "));
          DHT dht(2, DHT22);
          dht.begin();
          float humidity = dht.readHumidity();
          float temperature = dht.readTemperature();
          char humidity_str[6];
          char temperature_str[6];
          dtostrf(humidity, 2, 2, humidity_str);
          dtostrf(temperature, 2, 2, temperature_str);
          strcat(humidity_str, ";");
          strcpy(outgoing.message, strcat(humidity_str, temperature_str));
          Serial.print(outgoing.message);
          Serial.println();
        }
      }

      radio.stopListening();                                        // First, stop listening so we can talk

      radio.write( &outgoing, sizeof(payload_request_t) );              // Send the final one back.
      radio.startListening();                                       // Now, resume listening so we catch the next packets.
      Serial.print(F("Sent response "));
      Serial.println(outgoing.message);
   }
} // Loop

// 将str字符以spl分割,存于dst中，并返回子字符串数量
int split(char dst[][3], char* str, const char* spl)
{
    int n = 0;
    char *result = NULL;
    result = strtok(str, spl);
    while( result != NULL )
    {
        strcpy(dst[n++], result);
        result = strtok(NULL, spl);
    }
    return n;
}

