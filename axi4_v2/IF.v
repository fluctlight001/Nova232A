`include "lib/defines.vh"
module IF (
    input wire clk,
    input wire resetn,
    input wire stall,

    output reg [31:0] pc_reg,

    input wire [`BR_WD-1:0] br_bus,
    input wire [`BR_WD-1:0] bp_bus,

    output wire [31:0] current_pc1,
    output wire [31:0] current_pc2,

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

    wire bp_e;
    wire [31:0] bp_addr;

    reg r_br_e;
    reg [31:0] r_br_addr;

    reg r_bp_e;
    reg [31:0] r_bp_addr;
    
    assign {br_e, br_addr} = br_bus;
    assign {bp_e, bp_addr} = bp_bus;

    always @ (posedge clk) begin
        if (!resetn) begin
            pc_reg <= 32'hbfbf_fff8;
            r_br_e <= 1'b0;
            r_br_addr <= 32'b0;
            r_bp_e <= 1'b0;
            r_bp_addr <= 32'b0;
        end
        else if (!stall) begin
            pc_reg <= r_br_e ? {r_br_addr[31:3],3'b0} 
                    : br_e ? {br_addr[31:3],3'b0} 
                    : r_bp_e ? {r_bp_addr[31:3],3'b0}
                    : bp_e ? {bp_addr[31:3],3'b0} 
                    : {next_pc[31:3],3'b0};
            r_br_e <= 1'b0;
            r_bp_e <= 1'b0;
        end
        else if (br_e) begin
            r_br_e <= br_e;
            r_br_addr <= br_addr;
        end
        else if (bp_e) begin
            r_bp_e <= bp_e;
            r_bp_addr <= bp_addr;
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

    assign next_pc = pc_reg + 32'd8;

    assign ce_next = ~resetn ? 1'b0 : 1'b1;

    assign inst_sram_en = ce_reg;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc_reg;
    assign inst_sram_wdata = 32'b0;

    assign current_pc1 = br_e | r_br_e | bp_e | r_bp_e ? 32'b0 : {next_pc[31:3], 3'b000};
    assign current_pc2 = br_e | r_br_e | bp_e | r_bp_e ? 32'b0 : {next_pc[31:3], 3'b001};

endmodule