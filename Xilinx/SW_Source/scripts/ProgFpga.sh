#!/bin/sh

# Check if the argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <BandWidth kHz>"
  exit 1
fi

# Get the Bandwidth from the argument
BANDWIDTH=$1

BIT_BIN_PATH="/lib/firmware/xilinx/Radio_Top_v2_wrapper_${BANDWIDTH}k/Radio_Top_v2_wrapper.bit.bin"

# CHeck if the file exits
if [ ! -f "$BIT_BIN_PATH" ]; then
  echo "Error: File not fount - $BIT_BIN_PATH"
  exit 1
fi

# Program the FPGA
fpgautil -b "$BIT_BIN_PATH"
