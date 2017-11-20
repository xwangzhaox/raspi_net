#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>


int main(int argc, char* argv[])
{
  int fd;
  const char *s = "50_100_10";
  fd = open("/dev/ttyACM0", O_RDWR | O_NOCTTY | O_NDELAY);
  write(fd, s, sizeof(s));
  return 0;
}