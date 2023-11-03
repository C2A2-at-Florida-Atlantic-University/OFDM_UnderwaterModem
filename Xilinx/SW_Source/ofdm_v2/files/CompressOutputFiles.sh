#!/bin/sh

MOD_ORDER=$1
if [ $# -ne 1 ]; then
  echo "Enter Mod Order as first argument"
  exit 1
fi

tar -cvJf CompressedResults.tar.xz OfdmInfo1.txt \
RxDemodData$MOD_ORDER.txt \
RxFftSamples1.txt \
RxFreqData1.txt \
RxFreqDataEQ1.txt

du -bsh CompressedResults.tar.xz
