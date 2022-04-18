module tb_cmp(

);
    reg [4:0] ina, inb;
    wire [4:0] dout;

    addr_cmp u_addr_cmp(
    	.ina  (ina  ),
        .inb  (inb  ),
        .dout (dout )
    );

    initial begin
        ina = 5'b01011;
        inb = 5'b10011;
    end

    always # 10 begin
        ina = ina + 1'b1;
    end
    
endmodule