#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/media/saad/NVMe2/Xilinx/Vitis/2021.2/bin:/media/saad/NVMe2/Xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/media/saad/NVMe2/Xilinx/Vivado/2021.2/bin
else
  PATH=/media/saad/NVMe2/Xilinx/Vitis/2021.2/bin:/media/saad/NVMe2/Xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/media/saad/NVMe2/Xilinx/Vivado/2021.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/saad/Xilinx/UnderwaterModem/Updated_MyXilinx/3Vivado_HW/SDUAM.runs/SDUAM_auto_pc_9_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log SDUAM_auto_pc_9.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source SDUAM_auto_pc_9.tcl