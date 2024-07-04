import serial
import sys

print("")
print("  Usage: python3 reyax.py <ttyUSBx> <device_address>")
print("    to set address of device. If <device_address>")
print("    is empty, script will only read address")
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

# Set baud rate
ser.write(b'AT+IPR=115200\r\n')
response = ser.read(100)
print("Setting Baud Rate: ",response)

# Read baud rate
ser.write(b'AT+IPR?\r\n')
response = ser.read(100)
print("Reading Baud rate: ",response)

# Read RF Frequency
ser.write(b'AT+BAND?\r\n')
response = ser.read(100)
print("Reading RF Frequency: ",response)

# Read RF Parameters
ser.write(b'AT+PARAMETER?\r\n')
response = ser.read(100)
print("Reading RF Parameters: ",response)
# values_part = response.split('=')[1]
# values = values_part.split(',')
# print("

# Check if a command-line argument is provided
if len(sys.argv) > 2:
  print("Setting device address to: ",sys.argv[2])
  device_address = sys.argv[2]
  ser.write(f'AT+ADDRESS={device_address}\r\n'.encode())
  response = ser.read(100)
  print("Set Address: ", response)

# Read Address
ser.write(b'AT+ADDRESS?\r\n')
response = ser.read(100)
print("Reading Address: ",response)

# Read Network ID
ser.write(b'AT+NETWORKID?\r\n')
response = ser.read(100)
print("Reading Network ID: ",response)

# Read Output Power
ser.write(b'AT+CRFOP?\r\n')
response = ser.read(100)
print("Reading RF Output Power: ",response)

# Set all parameters to factory settings
# ser.write(b'AT+FACTORY\r\n')
# response = ser.read(100)
# print("Setting All Parameters to Factory Settings: ", response)

ser.close()
