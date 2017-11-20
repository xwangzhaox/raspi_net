#!/usr/bin/python
import serial, sqlite3, time
#import os, sqlite3, time
#from serial.serialutil import to_bytes

#d = to_bytes(command)
#serial = os.open('/dev/ttyACM0', os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
#os.write(serial, d)
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1);
while 1:
  time.sleep(3);
  conn = sqlite3.connect('/home/pi/workspace/raspi_net/server/db/sys.db')
  c = conn.cursor()
  print "Opened database successfully";

  cursor = c.execute("SELECT TEMP, HUMI FROM TEMP_HUMI ORDER BY ID DESC LIMIT 1")
  row = cursor.fetchone()
  command = str(round(row[1],2)) + "_" + str(round(row[0],2)) + "_" + str(time.strftime("%H", time.localtime()))

  print "Operation done successfully";
  conn.close()

  print command + "\n";

  ser.write(command);
  time.sleep(60*60);
  print(sum);