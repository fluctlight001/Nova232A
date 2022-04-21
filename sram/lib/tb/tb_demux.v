module tb_demux(

);
    reg [47:0] sel;
    reg [15:0] din;
    wire [15:0] dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0;
    // DEMUX_4_1 u_DEMUX_4_1(
    // 	.sel   (sel   ),
    //     .din   (din   ),
    //     .dout0 (dout0 ),
    //     .dout1 (dout1 ),
    //     .dout2 (dout2 ),
    //     .dout3 (dout3 )
    // );

    DEMUX_16 u_DEMUX_16(
    	.sel   (sel   ),
        .din   (din   ),
        .dout7 (dout7 ),
        .dout6 (dout6 ),
        .dout5 (dout5 ),
        .dout4 (dout4 ),
        .dout3 (dout3 ),
        .dout2 (dout2 ),
        .dout1 (dout1 ),
        .dout0 (dout0 )
    );
    
    
    initial begin
        sel = 0;
        din = 16'b1111111111111111;
    end

    always # 10
        sel = sel + 1;
    
endmodule