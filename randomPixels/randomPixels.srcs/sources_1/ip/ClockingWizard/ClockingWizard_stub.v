// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue Dec  1 14:54:48 2020
// Host        : LAPTOP-7KFHSKA6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Data/VHDLprojects2020/randomPixels/randomPixels.srcs/sources_1/ip/ClockingWizard/ClockingWizard_stub.v
// Design      : ClockingWizard
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ClockingWizard(PixelClk, Clk100Mhz, SysClk100MHz)
/* synthesis syn_black_box black_box_pad_pin="PixelClk,Clk100Mhz,SysClk100MHz" */;
  output PixelClk;
  output Clk100Mhz;
  input SysClk100MHz;
endmodule
