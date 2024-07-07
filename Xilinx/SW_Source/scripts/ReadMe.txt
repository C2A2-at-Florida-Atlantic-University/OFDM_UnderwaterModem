When flashing a new SD card, there are a few steps to set up the fpga-manager
device tree:

1. copy base.dtbo to /lib/firmware
2. copy /lib/firmware/xilinx/base/Radio_Top_v2_wrapper.bit.bin to /lib/firmware
3. Add these lines to /etc/init.d/bootmisc.sh
    cp /lib/firmware/xilinx/base/Radio_Top_v2_wrapper.bit.bin /lib/firmware
    echo 0 > /sys/class/fpga_manager/fpga0/flags
    mount -t configfs configfs /configfs
    cd /configfs/device-tree/overlays/
    mkdir full
    echo -n "base.dtbo" > full/path
