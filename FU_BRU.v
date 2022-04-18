`include "lib/defines.vh"
module FU_BRU(
    input wire clk,
    input wire resetn,

    input wire ready,

    input wire [11:0] op,
    input wire [`INST_STATE_WD-1:0] inst_status,
    input wire [31:0] rdata1, rdata2,

    output wire cb_we,
    output wire rf_we,
    output wire [31:0] wdata,
    output wire [31:0] extra_wdata,
    output wire br_e
);
    reg [11:0] r_op;
    reg [31:0] r_rdata1, r_rdata2;
    reg [`INST_STATE_WD-1:0] r_inst_status;

    always @ (posedge clk) begin
        if (!resetn) begin
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
    wire [31:0] br_addr;
    wire rs_eq_rt;
    wire rs_ge_z;
    wire rs_gt_z;
    wire rs_le_z;
    wire rs_lt_z;
    wire [31:0] pc_plus_4;

    wire inst_beq,  inst_bne,   inst_bgez,  inst_bgtz;
    wire inst_blez, inst_bltz,  inst_bgezal,inst_bltzal;
    wire inst_j,    inst_jal,   inst_jr,    inst_jalr;
    assign {
        inst_beq,   inst_bne,   inst_bgez,  inst_bgtz,
        inst_blez,  inst_bltz,  inst_bgezal,inst_bltzal,
        inst_j,     inst_jal,   inst_jr,    inst_jalr
    } = r_op;

    assign pc_plus_4 = r_inst_status[`PC] + 32'h4;
    assign rs_eq_rt = (r_rdata1 == r_rdata2);
    assign rs_ge_z  = ~r_rdata1[31];
    assign rs_gt_z  = ($signed(r_rdata1) > 0);
    assign rs_le_z  = (r_rdata1[31] == 1'b1 || r_rdata1 == 32'b0);
    assign rs_lt_z  = (r_rdata1[31]);

    assign br_e = inst_beq & rs_eq_rt
                | inst_bne & ~rs_eq_rt
                | inst_bgez & rs_ge_z
                | inst_bgtz & rs_gt_z
                | inst_blez & rs_le_z
                | inst_bltz & rs_lt_z
                | inst_bltzal & rs_lt_z
                | inst_bgezal & rs_ge_z
                | inst_j
                | inst_jr
                | inst_jal
                | inst_jalr;

    assign br_addr  = inst_beq   ? (pc_plus_4 + r_inst_status[`IMM]) 
                    : inst_bne   ? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_bgez  ? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_bgtz  ? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_blez  ? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_bltz  ? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_bltzal? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_bgezal? (pc_plus_4 + r_inst_status[`IMM])
                    : inst_j     ? r_inst_status[`IMM]
                    : inst_jr    ? r_rdata1 
                    : inst_jal   ? r_inst_status[`IMM]
                    : inst_jalr  ? r_rdata1 : 32'b0;

    assign cb_we = |r_op;
    assign rf_we = r_inst_status[`WE];
    assign wdata = (inst_jal | inst_bltzal | inst_bgezal | inst_jalr) ? r_inst_status[31:0] + 32'h8 : 32'b0;
    assign extra_wdata = br_addr;
endmodule