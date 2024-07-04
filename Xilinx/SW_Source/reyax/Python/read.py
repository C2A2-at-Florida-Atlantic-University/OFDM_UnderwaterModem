import serial
import sys

print("")
print("  Usage: python3 test.py <ttyUSBx>")
print("")

if len(sys.argv) < 2:
  print("Error: Set ttyUSBx device number")
  sys.exit(1)

tty_num = sys.argv[1]
serial_port = f'/dev/ttyUSB{tty_num}'

ser = serial.Serial(serial_port, 115200, timeout=1)

# Test if module can respond to commands
ser.write(b'AT\r\n')
response = ser.read(100)
print(response)

# Software reset
ser.write(b'AT+RESET\r\n')
response = ser.read(100)
print("Performing SW Reset: ",response)

ser.write(b'AT+RCV\r\n')
response = ser.read(100)
print(response)

ser.close()
