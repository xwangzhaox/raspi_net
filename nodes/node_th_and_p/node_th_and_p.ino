
/*
* Getting Started example sketch for nRF24L01+ radios
* This is a very basic example of how to send data from one node to another
* Updated: Dec 2014 by TMRh20
*/

#include <SPI.h>
#include "RF24.h"
#include "stdlib.h"
#include "DHT.h"

byte addresses[][8] = {"8a1isp","fvlest"};
char seps[]   = "_";
char *command;
int keep_time=0;
int pin=0;

struct payload_request_t{
  char message[15];
};

struct payload_general_t{
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

      Serial.print(F("Message: "));
      Serial.print(incoming.message);
      Serial.print(F("\n"));
      
      char dst[4][4];
      int cnt = split(dst, incoming.message, "_");
      if(strcmp(* &dst[0],"ol")==0){
        strcpy(outgoing.message, "OL");
      }else if(strcmp(&dst[1][0],"p")==0){
        Serial.print(F("PUT "));
        Serial.print(dst[0]);
        pin = atoi(dst[0]);
        pinMode(pin,OUTPUT);
        if(strcmp(* &dst[2],"on")==0){
          Serial.print(F(" ON."));
          digitalWrite(pin, HIGH);
          keep_time = atoi(dst[3]);
        }else{
          Serial.print(F(" OFF"));
          digitalWrite(pin, LOW);
        }
        delay(1000);
        Serial.print(F("\n"));
        strcpy(outgoing.message, "OK");
      }else if (strcmp(&dst[1][0],"g")==0){
        if(strcmp(* &dst[2],"th")==0){
          Serial.print(F("return th: "));
          pin = atoi(* &dst[0]);
          Serial.print(pin);
          DHT dht(pin, DHT22);
          dht.begin();
          float humidity = dht.readHumidity();
          float temperature = dht.readTemperature();
          char humidity_str[6];
          char temperature_str[6];
          dtostrf(humidity, 2, 2, humidity_str);
          dtostrf(temperature, 2, 2, temperature_str);
          strcat(humidity_str, "_");
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
      Serial.print(F("Keep time:"));
        Serial.print(keep_time);
        Serial.print(F("\n"));
      if(keep_time>1){
        delay(1000*keep_time);
        digitalWrite(pin, LOW); 
        keep_time = 0;
      }
   }
} // Loop

// 将str字符以spl分割,存于dst中，并返回子字符串数量
int split(char dst[][4], char* str, const char* spl)
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

