#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/saad/Xilinx/Vitis/2021.1/bin:/home/saad/Xilinx/Vivado/2021.1/ids_lite/ISE/bin/lin64:/home/saad/Xilinx/Vivado/2021.1/bin
else
  PATH=/home/saad/Xilinx/Vitis/2021.1/bin:/home/saad/Xilinx/Vivado/2021.1/ids_lite/ISE/bin/lin64:/home/saad/Xilinx/Vivado/2021.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/saad/Xilinx/2UnderwaterModem/MyXilinx/SDUAM/HW_Ver2/SDUAM.tmp/AXIS_Splitter_v1_0_project/AXIS_Splitter_v1_0_project.runs/synth_1'
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

EAStep vivado -log AXIS_Splitter_v1_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source AXIS_Splitter_v1_0.tcl
