// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Thu May  5 01:54:40 2022
// Host        : DESKTOP-PBDQAVR running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub D:/Project/mips32/Nova232A/axi4_v2/lib/dcache_tag/dcache_tag_stub.v
// Design      : dcache_tag
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.2" *)
module dcache_tag(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[6:0],d[20:0],clk,we,spo[20:0]" */;
  input [6:0]a;
  input [20:0]d;
  input clk;
  input we;
  output [20:0]spo;
endmodule
