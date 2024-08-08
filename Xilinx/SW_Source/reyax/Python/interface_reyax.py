import serial
import threading
import sys

# Configure the serial port
serial_port = '/dev/ttyUSB1'
self_address = 1
address = 2 # Address of conneced REYAX device
baud_rate = 115200
ser = serial.Serial(serial_port, baud_rate, timeout=1)

def read_from_reyax():
  print("Ready to Receive ...")
  while True:
    if ser.in_waiting > 0:
      data = ser.read(ser.in_waiting).decode('utf-8')
      if data:
        # Check if the data starts with +RCV=
        if data.startswith("+RCV="):
          try:
            # Remove the +RCV= prefix and split the rest by commas
            parts = data[5:].strip().split(',')
            rx_addr = parts[0]
            data_len = parts[1]
            received_data = parts[2]
            rssi = parts[3]
            snr = parts[4]
            # print(f"{received_data}        RSSI={rssi},SNR={snr}")
            print(f"{received_data}")
          except IndexError:
            #print("Error: Received data is not in the expected format")
            print(f"{data}")
        elif data.startswith("+OK"):
          pass
          # print(f"{data}")
        #else:
        #  print(f"Error: Expected +RCV=, Actual: {data}")

def send_to_reyax():
  print("Ready to Transmit ...")
  while True:
    user_input = input("")
    user_input_str_len = len(user_input)
    command = f'AT+SEND={address},{user_input_str_len},{user_input}\r\n'
    ser.write(command.encode('utf-8'))

if __name__ == "__main__":
  # Test if module can respond to commands
  ser.write(b'AT\r\n')
  response = ser.read(100)
  print(response)

  # Software reset
  ser.write(b'AT+RESET\r\n')
  response = ser.read(100)
  print("Performing SW Reset: ",response)

  # Read Self Address
  ser.write(b'AT+ADDRESS?\r\n')
  response = ser.read(100)
  print("Reading Self Address: ",response)
  print("Connecting Address: ",address)

  # Read Network ID
  ser.write(b'AT+NETWORKID?\r\n')
  response = ser.read(100)
  print("Reading Network ID: ",response)

  # Start thread for reading data
  read_thread = threading.Thread(target=read_from_reyax)
  read_thread.daemon = True
  read_thread.start()

  # Start the function for sending data (runs in main thread)
  send_to_reyax()
