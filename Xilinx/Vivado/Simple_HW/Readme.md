Notes: AXI Smart Connect changed to AXI Interconnect to conserve resources. 
  AXI GPIO changed to dual AXI GPIO to reduce number of Master AXI buses off
  AXI Interconnect which greatly reduces resource utalization. AXI DMA took
  1722 LUTs (max burst size 256), 1650 (max burst size 2), 1613 (width of 
  buffer length register (from 26 to 15).
