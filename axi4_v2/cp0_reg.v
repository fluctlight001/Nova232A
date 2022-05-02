`include "lib/defines.vh"

module cp0_reg(
    input wire clk,
    input wire resetn,
    
    input wire cp0_en,
    input wire cp0_wen,
    input wire [4:0] cp0_addr,
    input wire [31:0] cp0_wdata,
    output wire [31:0] cp0_rdata
);
    reg tick;
    reg [31:0] c0_count;
    always @ (posedge clk) begin
        if (!resetn) begin
            tick <= 1'b0;
        end
        else begin
            tick <= ~tick;
        end
        if (!resetn) begin
            c0_count <= 32'b0;
        end
        else if (cp0_wen && cp0_addr == `CP0_REG_COUNT)begin
            c0_count <= cp0_wdata;
        end
        else if (tick) begin
            c0_count <= c0_count + 1'b1;
        end
    end

    assign cp0_rdata = cp0_en & ~cp0_wen ? c0_count : 32'b0;
endmodule
