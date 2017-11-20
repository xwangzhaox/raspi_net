#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sqlite3.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  time_t theTime = time(NULL);
  struct tm *aTime = localtime(&theTime);
  char command[100];
  sprintf(command, "%s_%s_%s", argv[1], argv[0], argv[2]);
  printf("%s \n", command);

  int fd;
  fd = open("/dev/ttyACM0", O_RDWR | O_NOCTTY | O_NDELAY);
  write(fd, command, sizeof(command));

  return 0;
}

int main(int argc, char* argv[])
{
  sqlite3 *db;
  char *zErrMsg = 0;
  int  rc;
  const char *sql;

  while(true)
  {
    /* Open database */
    rc = sqlite3_open("/home/pi/workspace/raspi_net/server/db/sys.db", &db);
    if( rc ){
      fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
      exit(0);
    }else{
      fprintf(stdout, "Opened database successfully\n");
    }

    sql = "SELECT TEMP, HUMI, strftime('%H',CREATED) FROM TEMP_HUMI ORDER BY ID DESC LIMIT 1";

    /* Execute SQL statement */
    rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
    if( rc != SQLITE_OK ){
      fprintf(stderr, "SQL error: %s\n", zErrMsg);
      sqlite3_free(zErrMsg);
    }else{
      fprintf(stdout, "Send data successfully\n");
    }
    sqlite3_close(db);

//sleep(60*60);
    sleep(10);
  }
    return 0;
}