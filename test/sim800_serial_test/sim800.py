import serial
import time

ser = serial.Serial("/dev/ttyS0", 9600)
def main():
  while True:
    count = ser.inWaiting()
    if count != 0:
      recv = ser.read(count)
      ser.write(recv)
    ser.flushInput()
    time.sleep(0.1)

if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    if ser != None:
      ser.close()
