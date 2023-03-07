#!/bin/bash
# Jared Hermans

DRIVE=$1
if [ $# -ne 1 ]; then
  echo "Enter drive as first argument"
  exit 1
fi

cd images/linux
echo "Mounting drive ..."
sudo mkdir /mnt/$DRIVE
sudo mount -t drvfs $DRIVE: /mnt/$DRIVE
rm /mnt/$DRIVE/BOOT.BIN /mnt/$DRIVE/boot.scr /mnt/$DRIVE/image.ub
cp Updated_BOOT.BIN /mnt/$DRIVE/BOOT.BIN
cp image.ub boot.scr /mnt/$DRIVE/
sudo umount /mnt/$DRIVE
sudo rm -r /mnt/$DRIVE
# If rootfs has been modified or kernel drivers have been modified then untar rootfs.tar.gz on /media/<uname>/rootfs
# cp rootfs.tar.gz /mnt/c/Users/herma/Downloads/
