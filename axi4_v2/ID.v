`include "lib/defines.vh"
module ID (
    input wire clk,
    input wire resetn,

    input wire stall,
    input wire [`BR_WD-1:0] br_bus,
    input wire [`BR_WD-1:0] bp_bus,
    input wire next_inst_invalid,    
    // IF
    input wire [31:0] pc,
    input wire [63:0] inst_sram_rdata,
    // scoreboard
    output wire inst1_valid,
    output wire [`ID_TO_SB_WD-1:0] inst1,
    output wire inst2_valid,
    output wire [`ID_TO_SB_WD-1:0] inst2
);

    wire br_e;
    wire [31:0] br_addr;
    assign {br_e, br_addr} = br_bus;

    wire bp_e;
    wire [31:0] bp_addr;
    assign {bp_e, bp_addr} = bp_bus;

    reg [31:0] easy_pc;
    reg [31:0] sram_pc, pc_r;
    reg [63:0] inst_sram_rdata_r;

    wire easy_match;
    assign easy_match = easy_pc[31:3] == pc_r[31:3] ? 1'b1 : 1'b0;

    always @ (posedge clk) begin
        if (!resetn) begin
            easy_pc <= 32'hbfc0_0000;
        end
        else if (br_e) begin
            easy_pc <= br_addr;
        end
        else if (bp_e & ~stall) begin
            easy_pc <= bp_addr;
        end
        else if (inst1_valid&inst2_valid) begin
            easy_pc <= easy_pc + 32'd8;
        end
        else if (inst2_valid) begin
            easy_pc <= easy_pc + 32'd4;
        end
    end

    always @ (posedge clk) begin
        if (!resetn | br_e) begin
            sram_pc <= 32'b0;
        end
        else if (!stall) begin
            sram_pc <= pc;
        end
    end

    reg flag;
    reg [31:0] buf_pc;
    reg [63:0] buf_inst;

    always @ (posedge clk) begin
        if (stall & !flag) begin
            buf_pc <= sram_pc;
            buf_inst <= inst_sram_rdata;
        end
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            pc_r <= 32'b0;
            inst_sram_rdata_r <= 64'b0;
            flag <= 1'b0;
        end
        else if (!stall) begin
            pc_r <= flag ? buf_pc : sram_pc;
            inst_sram_rdata_r <= flag ? buf_inst : inst_sram_rdata;
            flag <= 1'b0;
        end
        else if (!flag) begin
            flag <= 1'b1;
        end
    end

    wire dcd1_valid, dcd2_valid;
    decoder 
    #(
        .sel_arr (4'b1000 )
    )
    u0_decoder(
    	.clk          (clk          ),
        .resetn       (resetn       ),
        .stall        (stall        ),
        .pc           ({pc_r[31:3], 3'b000}          ),
        .inst         (inst_sram_rdata_r[31:0]         ),
        .inst_valid   (dcd1_valid   ),
        .inst_info    (inst1        )
    );

    decoder 
    #(
        .sel_arr (4'b0010 )
    )
    u1_decoder(
    	.clk          (clk          ),
        .resetn       (resetn       ),
        .stall        (stall        ),
        .pc           ({pc_r[31:3], 3'b100}          ),
        .inst         (inst_sram_rdata_r[63:32]         ),
        .inst_valid   (dcd2_valid   ),
        .inst_info    (inst2        )
    );
    
    assign inst1_valid = dcd1_valid & easy_match & ~easy_pc[2];
    assign inst2_valid = dcd2_valid & easy_match & ~next_inst_invalid;

endmodule