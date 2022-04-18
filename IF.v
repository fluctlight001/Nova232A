`include "lib/defines.vh"
module IF (
    input wire clk,
    input wire resetn,
    input wire stall,

    output reg [31:0] pc_reg,

    input wire [`BR_WD-1:0] br_bus,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata
); 

    wire [31:0] next_pc;
    // wire [32:0] br_bus;
    // assign br_bus = 0;


    // reg [31:0] pc_reg;
    reg ce_reg;
    wire ce_next;

    wire br_e;
    wire [31:0] br_addr;
    
    assign {br_e, br_addr} = br_bus;

    always @ (posedge clk) begin
        if (!resetn) begin
            pc_reg <= 32'hbfbf_fffc;
        end
        else if (!stall) begin
            pc_reg <= next_pc;
        end
        else if (br_e) begin
            pc_reg <= br_addr;
        end
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            ce_reg <= 1'b0;
        end
        else if (!stall) begin
            ce_reg <= ce_next;
        end
    end

    assign next_pc = br_e ? br_addr :
                 pc_reg + 32'd4;

    assign ce_next = ~resetn ? 1'b0 : 1'b1;

    assign inst_sram_en = ce_next;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = next_pc;
    assign inst_sram_wdata = 32'b0;

endmodule