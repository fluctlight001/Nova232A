module addr_cmp(
    input wire [4:0] ina, inb,
    output wire [4:0] dout
);
    wire pos_cmp;
    wire addr_cmp;
    assign pos_cmp = ina[4]^inb[4];
    assign addr_cmp = ina[3:0] > inb[3:0] ? 1 : 0;
    assign dout = pos_cmp^addr_cmp ? inb : ina;
endmodule
