#!/bin/bash

# To untar: "tar -xJf ..."
tar -cJf InputFiles.tar.xz FIR* Pilot* *.sh TxMod* zc*
echo "Wrote to InputFiles.tar.xz"

# To untar: "tar -xjf ..."
tar -cjf InputFiles.tar.bz2 FIR* Pilot* *.sh TxMod* zc*
echo "Wrote to InputFiles.tar.bz2"

7z a -t7z InputFiles.7z FIR* Pilot* *.sh TxMod* zc*
echo "Wrote to InputFiles.7z"

du -bsh InputFiles.tar.xz InputFiles.tar.bz2 InputFiles.7z
