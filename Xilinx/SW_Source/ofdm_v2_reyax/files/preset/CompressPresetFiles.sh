#!/bin/zsh

tar -cJf PresetArchive.tar.xz preset*
echo "Wrote to PresetArchive.tar.xz"

du -bsh PresetArchive.tar.xz
