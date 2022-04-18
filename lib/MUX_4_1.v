module MUX_4_1(
    input wire [1:0] sel,
    input wire [4:0] din0, din1, din2, din3,
    output reg [4:0] dout
);
    always @ (*) begin
        case (sel) 
            2'b00:dout = din0;
            2'b01:dout = din1;
            2'b10:dout = din2;
            2'b11:dout = din3;
        endcase
    end
endmodule