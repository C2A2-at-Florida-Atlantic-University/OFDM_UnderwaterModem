#!/bin/sh

# Check if the argument is provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <BandWidth kHz> <optional: ADC_ILA>"
  exit 1
fi

# Get the Bandwidth from the argument
BANDWIDTH=$1
# Get the ILA location from the second argument
ILA_MODE=$2

if [ "$ILA_MODE" = "ADC_ILA" ]; then
  echo "Selecting ADC_ILA bitfile"
  BIT_BIN_PATH="/lib/firmware/xilinx/Radio_Top_v2_wrapper_${BANDWIDTH}k_${ILA_MODE}/Radio_Top_v2_wrapper.bit.bin"
elif [ -n "$ILA_MODE" ]; then
  echo "Unknown ILA location"
  echo "Usage: $0 <BandWidth kHz> <optional: ADC_ILA>"
  exit 1
else
  echo "No ILA location selected. Default ILA location at Synchronizer"
  BIT_BIN_PATH="/lib/firmware/xilinx/Radio_Top_v2_wrapper_${BANDWIDTH}k/Radio_Top_v2_wrapper.bit.bin"
fi


# CHeck if the file exits
if [ ! -f "$BIT_BIN_PATH" ]; then
  echo "Error: File not fount - $BIT_BIN_PATH"
  exit 1
fi

# Program the FPGA
fpgautil -b "$BIT_BIN_PATH"
