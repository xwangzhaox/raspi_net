#!/usr/bin/python
import os, sqlite3, time
from serial.serialutil import to_bytes

conn = sqlite3.connect('/home/pi/workspace/raspi_net/server/db/sys.db')
c = conn.cursor()
print "Opened database successfully";

cursor = c.execute("SELECT TEMP, HUMI FROM TEMP_HUMI ORDER BY ID DESC LIMIT 1")
row = cursor.fetchone()
command = str(round(row[0],2)) + "_" + str(round(row[1],2)) + "_" + str(time.strftime("%H", time.localtime()))

print "Operation done successfully";
conn.close()

print command + "\n";

d = to_bytes(command)
serial = os.open('/dev/ttyACM0', os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
os.write(serial, d)