#!/bin/bash
# Jared Hermans

rm *.xsa
cp $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.xsa .
petalinux-config --get-hw-description=./ --silentconfig
