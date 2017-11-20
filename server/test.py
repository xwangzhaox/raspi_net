import serial, time
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
time.sleep(3)
ser.write("50_100_10")
ser.close()