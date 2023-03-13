#!/bin/bash
# Jared Hermans

rm *.xsa
cp $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/Radio_Top_Pynq_wrapper.xsa .
petalinux-config --get-hw-description=./ --silentconfig
