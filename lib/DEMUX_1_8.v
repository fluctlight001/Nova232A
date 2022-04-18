module DEMUX_1_8(
    input wire [2:0] sel,
    input wire din,
    output reg dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0
);
    always @ (*) begin
        case(sel)
            3'b000:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {7'b0,din};
            3'b001:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {6'b0,din,1'b0};
            3'b010:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {5'b0,din,2'b0};
            3'b011:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {4'b0,din,3'b0};
            3'b100:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {3'b0,din,4'b0};
            3'b101:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {2'b0,din,5'b0};
            3'b110:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {1'b0,din,6'b0};
            3'b111:{dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0} = {din,7'b0};
        endcase
    end
endmodule    