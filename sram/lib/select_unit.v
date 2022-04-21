module select_unit(
    input wire ready0, ready1,
    input wire [4:0] addr0, addr1,
    output wire ready01,
    output wire [4:0] addr01
);
    wire [1:0] sel;
    wire [4:0] din0, din1, din2, din3;
    wire [4:0] dout;
    MUX_4_1 u_MUX_4_1(
    	.sel  (sel  ),
        .din0 (din0 ),
        .din1 (din1 ),
        .din2 (din2 ),
        .din3 (din3 ),
        .dout (dout )
    );

    assign sel = {ready1, ready0};
    assign din0 = addr0;
    assign din1 = addr0;
    assign din2 = addr1;
    
    addr_cmp u_addr_cmp(
    	.ina  (addr0  ),
        .inb  (addr1  ),
        .dout (din3   )
    );
    
    assign ready01 = ready0 | ready1;
    assign addr01 = dout;   
    
endmodule