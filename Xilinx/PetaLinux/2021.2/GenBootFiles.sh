#!/bin/bash
# Jared Hermans

cd $PetaLinuxPath
cd images/linux
# petalinux-package --boot --fsbl zynq_fsbl.elf --fpga $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.runs/impl/Radio_Top_Pynq_wrapper.bit --u-boot u-boot.elf --dtb system.dtb -o Updated_BOOT.BIN --force
petalinux-package --boot --fsbl zynq_fsbl.elf --fpga system.bit --u-boot u-boot.elf --dtb system.dtb -o Updated_BOOT.BIN --force
