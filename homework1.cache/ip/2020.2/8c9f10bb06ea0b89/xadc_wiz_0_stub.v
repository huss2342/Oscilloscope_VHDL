// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Sun Apr  7 20:51:02 2024
// Host        : DESKTOP-TBLU0CF running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ xadc_wiz_0_stub.v
// Design      : xadc_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(daddr_in, den_in, di_in, dwe_in, do_out, drdy_out, 
  dclk_in, reset_in, vauxp4, vauxn4, vauxp12, vauxn12, busy_out, channel_out, eoc_out, eos_out, 
  alarm_out, vp_in, vn_in)
/* synthesis syn_black_box black_box_pad_pin="daddr_in[6:0],den_in,di_in[15:0],dwe_in,do_out[15:0],drdy_out,dclk_in,reset_in,vauxp4,vauxn4,vauxp12,vauxn12,busy_out,channel_out[4:0],eoc_out,eos_out,alarm_out,vp_in,vn_in" */;
  input [6:0]daddr_in;
  input den_in;
  input [15:0]di_in;
  input dwe_in;
  output [15:0]do_out;
  output drdy_out;
  input dclk_in;
  input reset_in;
  input vauxp4;
  input vauxn4;
  input vauxp12;
  input vauxn12;
  output busy_out;
  output [4:0]channel_out;
  output eoc_out;
  output eos_out;
  output alarm_out;
  input vp_in;
  input vn_in;
endmodule
