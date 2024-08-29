When flashing a new SD card, there are a few steps to set up the fpga-manager
device tree and other things:

1. copy base.dtbo to /lib/firmware then run "mkdir /configfs"
2. Add these lines to the end of /etc/init.d/bootmisc.sh
    cp /lib/firmware/xilinx/base/Radio_Top_v2_wrapper.bit.bin /lib/firmware
    echo 0 > /sys/class/fpga_manager/fpga0/flags
    mount -t configfs configfs /configfs
    cd /configfs/device-tree/overlays/
    mkdir full
    echo -n "base.dtbo" > full/path
3. To get rid of annoying repeating message comment out last line in
   /etc/inittab (1:12345:respawn:/sbin/getty 38400 tty1)
4. To get rid of udev error boot messages run:
   rm -rf /sbin/udevd /lib/udev /etc/init.d/udev
5. To get rid of annoying bootlogd boot error message:
   rm -f /sbin/bootlogd
6. To get rid of annoying hwclock boot error message put exit 0
   as first line in /etc/init.d/hwclock.sh
7. To get rid of annoying networking boot error messages put
   "exit 0" at second line of /etc/init.d/networking after "PATH" line
8. To get rid of u-boot message 
   "Loading Environment from FAT... *** Warning - bad CRC, using default environment"
   run "saveenv" in u-boot
