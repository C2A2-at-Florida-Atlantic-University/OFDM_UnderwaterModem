#!/bin/bash
# Jared Hermans

# Linux (or WSL) only
# Set PetaLinuxPathPynq to directory to create PetaLinux project for Pynq-Z2 dev board

cd $PetaLinuxPathPynq

# Create Project
petalinux-create --type project --template zynq --name pynq-z2
cd pynq-z2
cp $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/Radio_Top_Pynq_wrapper.xsa .

# Configure with FPGA HW
petalinux-config --get-hw-description=./ --silentconfig

# Configure rootfs
echo CONFIG_lrzsz=y > project-spec/configs/rootfs_config

cd $FAU_OFDM_REPO_PATH/Xilinx/PetaLinux/2021.2/
cp CopyToSd_WSL.sh $PetaLinuxPathPynq/pynq-z2
cp FpgaXSA.sh $PetaLinuxPathPynq/pynq-z2
cp GenBootFiles.sh $PetaLinuxPathPynq/pynq-z2
