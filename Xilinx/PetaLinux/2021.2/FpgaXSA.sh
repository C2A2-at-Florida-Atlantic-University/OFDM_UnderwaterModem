#!/bin/bash
# Jared Hermans

cd $PetaLinuxPath
rm *.xsa
#cp $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/Radio_Top_Pynq_wrapper.xsa .
cp $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_v2/Radio_Top_v2_wrapper.xsa .
petalinux-config --get-hw-description=./ --silentconfig
