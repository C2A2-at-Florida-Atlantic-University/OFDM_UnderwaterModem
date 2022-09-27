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

HD_PWD='/media/saad/NVMe2/UnderwaterModem/Updated_MyXilinx/3_Simple_HW/SDUAM.runs/impl_1'
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

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log SDUAM_wrapper.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source SDUAM_wrapper.tcl -notrace


