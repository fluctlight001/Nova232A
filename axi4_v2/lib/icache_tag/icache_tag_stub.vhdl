-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Thu May  5 01:55:19 2022
-- Host        : DESKTOP-PBDQAVR running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub D:/Project/mips32/Nova232A/axi4_v2/lib/icache_tag/icache_tag_stub.vhdl
-- Design      : icache_tag
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity icache_tag is
  Port ( 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 );
    d : in STD_LOGIC_VECTOR ( 20 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    spo : out STD_LOGIC_VECTOR ( 20 downto 0 )
  );

end icache_tag;

architecture stub of icache_tag is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a[5:0],d[20:0],clk,we,spo[20:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dist_mem_gen_v8_0_13,Vivado 2019.2";
begin
end;
