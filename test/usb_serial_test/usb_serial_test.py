import serial
ser = serial.Serial('/dev/ttyACM0', 9600)
ser.write("28.18_83.31_19")
ser.close()