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

# Check mode
ser.write(b'AT+MODE?\r\n')
response = ser.read(100)
print("Checking Wireless Mode: ", response)

ser.write(b'AT+SEND=2,21,Hello From Computer 1\r\n')
# ser.write(b'AT+SEND=0,0,\r\n')
response = ser.read(100)
print("Sending Data: ",response)

# ser.write(b'AT+SEND?\r\n')
# response = ser.read(100)
# print("Search last transmit data: ", response)

ser.write(b'AT+SEND=2,21,Hello From Computer 2\r\n')
response = ser.read(100)
print("Sending Data: ",response)

# ser.write(b'AT+SEND?\r\n')
# response = ser.read(100)
# print("Search last transmit data: ", response)

ser.close()
