#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sqlite3.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


int main(int argc, char* argv[])
{
  int fd;
  char command[] = "18_100_10";
  fd = open("/dev/ttyACM0", O_RDWR | O_NOCTTY | O_NONBLOCK);
  while(true){
  sleep(2);
  write(fd, command, sizeof(command));
  sleep(6);
  }
}
