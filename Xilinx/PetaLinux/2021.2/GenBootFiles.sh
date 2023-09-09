#!/bin/bash
# Jared Hermans

cd $PetaLinuxPath
cd images/linux
#petalinux-package --boot --fsbl zynq_fsbl.elf --fpga $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_v2_reload/radio_top_v2_reload.runs/impl_1/Radio_Top_v2_wrapper.bit --u-boot u-boot.elf --dtb system.dtb -o Updated_BOOT.BIN --force
#petalinux-package --boot --fsbl zynq_fsbl.elf --fpga system.bit --u-boot u-boot.elf --dtb system.dtb -o Updated_BOOT.BIN --force
petalinux-package --boot --fsbl zynq_fsbl.elf --fpga /mnt/c/Projects/FAU-Modem/FH-FSK/UnderwaterModem/Updated_MyXilinx/MODEM_HW/SDUAM.runs/impl_1/SDUAM_wrapper.bit --u-boot u-boot.elf --dtb system.dtb -o Updated_BOOT.BIN --force

