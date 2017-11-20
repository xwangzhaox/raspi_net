#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <RF24/RF24.h>
#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

using namespace std;

RF24 radio(22,0);

enum commands {pOn, pOff, getAirTH};
const uint8_t pipes[][6]= {"S1", "N2"};

struct payload_request_t{
  char message[15];
};

struct payload_general_t{
//  int command;
//  int destination;
  char message[14];
};
float th[2];

payload_request_t incoming;
payload_general_t outgoing;

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for(i = 0; i< argc; i++){
    printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");
  return 0;
}

int main(int argc, char** argv){
  cout << "Raspiberry pi Server Output:\n";
  // confirm args and cat commands
  // confirm first args
  if (strcmp(argv[2], "p")==0){
    // confirm the third args
    // confirm the second args and cat command
    if (strcmp(argv[3], "on")==0){
      char str[] = "p_on_";
      strcpy(outgoing.message, strcat(str, argv[4]));
    }else if(strcmp(argv[3], "off")==0){
      char str[] = "p_off_";
      strcpy(outgoing.message, strcat(str, argv[4]));
    }else{
      printf("Pin command error.");
      return 0;
    }
  }else if (strcmp(argv[2], "g")==0){
    if(strcmp(argv[3], "th")==0){
      strcpy(outgoing.message, "g_th");
    }
  }else{
    printf("Argument Error: First arg error.");
  }
  radio.begin();

  radio.setRetries(15,15);

  radio.printDetails();

  radio.openWritingPipe(pipes[0]);

  // init node port
  uint8_t node[6] = {};
  int i,lenth = strlen(argv[1]);
  for(i=0;i<lenth;i++)
    node[i] = *(uint8_t *) & argv[1][i];
  printf("%d\n", sizeof(node));
  radio.openReadingPipe(1,node);

  radio.startListening();

  int retry = 0;
  while (1)
  {
    radio.stopListening();

    printf("Now sending...\n");

    printf("Command: %s\n", outgoing.message);
    //unsigned long time = millis();

    bool ok = radio.write( &outgoing,sizeof(payload_general_t)+1 );
    //char command[10] = "on_2";
    //bool ok = radio.write( &command,sizeof(command)+1 );

    if (!ok){
      printf("Sending Error.\n");
    }

    radio.startListening();

    retry = retry + 1;
    printf("%d", retry);
    unsigned long started_waiting_at = millis();
    bool timeout = false;
    while ( ! radio.available() && ! timeout ) {
    if (millis() - started_waiting_at > 200 )
      timeout = true;
    }

    if ( timeout ){
      printf("Failed, response timed out.\n");
    }else{
      radio.read(&incoming, sizeof(payload_request_t));

      printf("Got response %s, round-trip delay: %lu\n",incoming.message, millis()-started_waiting_at);
      //printf("\n %d \n", sizeof(incoming.message));
      char ruby_shell[]= "ruby ~/workspace/remote_server/socket_client.rb ";
      strcpy(ruby_shell, outgoing.message);
      strcpy(ruby_shell, incoming.message);
      system(ruby_shell);

     // printf("%s", incoming.message);
     // int n = 0;
     // char *result = NULL;
     // result = strtok(incoming.message, ";");
     // while( result != NULL )
     // {
     //   th[n] = atof(result);
     //   n++;
     //   result = strtok(NULL, ";");
     // }

     // if(th[0]!=0.0 and th[1]!=0.0){
     //   sqlite3 *db;
     //   char *zErrMsg = 0;
     //   int rc;
     //   char *sql;

     //   rc = sqlite3_open("/home/pi/workspace/raspi_net/server/db/sys.db", &db);
     //   if(rc){
     //     fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
     //     exit(0);
     //   }else{
     //     fprintf(stdout, "Opened database successfully\n");
     //   }

     //   char s[100];
     //   sprintf(s, "INSERT INTO TEMP_HUMI (CREATED, TYPE, TEMP, HUMI) VALUES (datetime(), 0, %2f, %2f);", th[0], th[1]);
     //   sql = s;

     //   rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
     //   if(rc != SQLITE_OK){
     //     fprintf(stderr, "SQL error: %s\n", zErrMsg);
     //     sqlite3_free(zErrMsg);
     //   }else{
     //     sqlite3_close(db);
     //   }
     // }else{
     //   printf("Error!");
     // }

      break;
    }
    sleep(1);
    if(retry>=5){
      printf("Error: nothing received!");
      break;
    }

  }
  return 0;
}

