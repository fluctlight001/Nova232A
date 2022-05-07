`include "lib/defines.vh"
module FU_ALU(
    input wire clk,
    input wire resetn,
    input wire flush,

    input wire ready,

    input wire [11:0] op,
    input wire [`INST_STATE_WD-1:0] inst_status,
    input wire [31:0] rdata1, rdata2,

    output wire cb_we,
    output wire rf_we,
    output wire [31:0] wdata
);
    reg [11:0] r_op;
    reg [31:0] r_rdata1, r_rdata2;
    reg [`INST_STATE_WD-1:0] r_inst_status;

    always @ (posedge clk) begin
        if (!resetn | flush) begin
            r_op <= 12'b0;
            r_rdata1 <= 32'b0;
            r_rdata2 <= 32'b0;
            r_inst_status <= `INST_STATE_WD'b0;
        end
        else if (ready) begin
            r_op <= op;
            r_rdata1 <= rdata1;
            r_rdata2 <= rdata2;
            r_inst_status <= inst_status;
        end    
        else begin
            r_op <= 12'b0;
            r_rdata1 <= 32'b0;
            r_rdata2 <= 32'b0;
            r_inst_status <= `INST_STATE_WD'b0;
        end
    end

    wire [11:0] alu_control;
    wire [31:0] alu_src1, alu_src2;
    wire [31:0] alu_result;

    assign alu_control = r_op;
    assign alu_src1 = r_inst_status[`SEL1] ? r_inst_status[`IMM] : r_rdata1;
    assign alu_src2 = r_inst_status[`SEL2] ? r_inst_status[`IMM] : r_rdata2;
    
    alu u_alu(
    	.alu_control (alu_control ),
        .alu_src1    (alu_src1    ),
        .alu_src2    (alu_src2    ),
        .alu_result  (alu_result  )
    );

    assign cb_we = |r_op;
    assign rf_we = r_inst_status[`WE];
    // assign waddr = r_inst_status[`ADDR]; // ROB ADDR
    assign wdata = alu_result;

endmodule