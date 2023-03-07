#!/bin/bash -x
# Jared Hermans

# This script replaces the fixed path XILINX requires for some
# files with the fixed path of YOUR project location

# You must set environment variable FAU_OFDM_REPO_PATH to the 
# location you have cloned this repo

# If on windows, run with git cmd (MINGW)

set +x
echo
echo "Environment Setup Script - set PI_RADIO_REPO_PATH env variable first"
echo Your repo path: \$FAU_OFDM_REPO_PATH = $FAU_OFDM_REPO_PATH
echo

cd Xilinx/Vivado/bd
set -x
sed -i "s|/mnt/c/Projects/FAU-Modem/OFDM|$FAU_OFDM_REPO_PATH|g" Transmit_Chain_bd.tcl
set +x
echo
echo "NOTE: Remember to set PetaLinuxPath and PetaLinuxPathPynq environment variables to build PetaLinux projects for FAU-Modem and Pynq-z2"
echo
