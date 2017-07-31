/*
 Copyright (C) 2011 J. Coliz <maniacbug@ymail.com>

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 version 2 as published by the Free Software Foundation.

 03/17/2013 : Charles-Henri Hallard (http://hallard.me)
              Modified to use with Arduipi board http://hallard.me/arduipi
						  Changed to use modified bcm2835 and RF24 library
TMRh20 2014 - Updated to work with optimized RF24 Arduino library

 */

/**
 * Example RF Radio Ping Pair
 *
 * This is an example of how to use the RF24 class on RPi, communicating to an Arduino running
 * the GettingStarted sketch.
 */

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <RF24/RF24.h>

using namespace std;

RF24 radio(22,0);

/********** User Config *********/
// Assign a unique identifier for this node, 0 or 1
// Received port 1, send port 0

/********************************/

// Radio pipe addresses for the 2 nodes to communicate.
const uint8_t pipes[][6] = {"RPi3"};


int main(int argc, char** argv){
  pipes.insert(argv[1]);

  cout << "RF24/examples_linux/power_control/\n";

  // Setup and configure rf radio
  radio.begin();

  // optionally, increase the delay between retries & # of retries
  radio.setRetries(15,15);
  // Dump the configuration of the rf unit for debugging
  radio.printDetails();

/***********************************/
    radio.openWritingPipe(pipes[1]);
    radio.openReadingPipe(1,pipes[0]);
	
    // Take the time, and send it.  This will block until complete
    
    printf("Now sending...\n");
    unsigned long time = millis();
    
    bool ok = radio.write( argv[2], 1 );
    
    if (!ok){
    	printf("failed.\n");
    }
    // Now, continue listening
    radio.startListening();
    
    // Wait here until we get a response, or timeout (250ms)
    unsigned long started_waiting_at = millis();
    bool timeout = false;
    while ( ! radio.available() && ! timeout ) {
    	if (millis() - started_waiting_at > 200 )
    		timeout = true;
    }
    
    
    // Describe the results
    if ( timeout )
    {
    	printf("Failed, response timed out.\n");
    }
    else
    {
    	// Grab the response, compare, and send to debugging spew
    	unsigned long got_time;
    	radio.read( &got_time, sizeof(unsigned long) );
    
    	// Spew it
    	printf("[Power %s]Command execute success.Got response %lu, round-trip delay: %lu\n", argv[2]==1?"On":"False",got_time,millis()-got_time);
    }
    sleep(1);
  return 0;
}

