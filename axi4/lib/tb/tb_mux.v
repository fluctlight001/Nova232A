module tb_mux(

);
    reg [1:0] sel;
    reg [4:0] din0, din1, din2, din3;
    wire [4:0] dout;
    MUX_4_1 u_MUX_4_1(
    	.sel  (sel  ),
        .din0 (din0 ),
        .din1 (din1 ),
        .din2 (din2 ),
        .din3 (din3 ),
        .dout (dout )
    );

    initial begin
        sel = 0;
        din0 = 0;
        din1 = 1;
        din2 = 2;
        din3 = 3;
    end

    always #10
        sel = sel + 1;
    
endmodule