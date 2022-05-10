`include "lib/defines.vh"
module bpu(
    input wire clk,
    input wire resetn,

    input wire [31:0] current_pc1,
    input wire [31:0] current_pc2,

    input wire [`BR_WD-1:0] br_bus,
    input wire [31:0] delayslot_pc,

    output wire next_inst_invalid,
    output wire [`BR_WD-1:0] bp_bus
);
    wire hit_way1;
    wire hit_way2;
    wire br_e;
    wire [31:0] br_target;
    wire bp_e;
    wire [31:0] bp_target;
    reg valid;
    reg [31:0] branch_history_pc;
    reg [31:0] branch_target;
    
    assign {br_e, br_target} = br_bus;
    assign bp_bus = {bp_e, bp_target};

    always @ (posedge clk) begin
        if (!resetn) begin
            valid <= 1'b0;
            branch_history_pc <= 32'b0;
            branch_target <= 32'b0;
        end
        else if (br_e) begin
            valid <= 1'b1;
            branch_history_pc <= delayslot_pc;
            branch_target <= br_target;
        end
    end

    assign hit_way1 = valid & (branch_history_pc == current_pc1);
    assign hit_way2 = valid & (branch_history_pc == current_pc2);

    assign next_inst_invalid = hit_way1;

    assign bp_e = hit_way1 | hit_way2;
    assign bp_target = branch_target;



endmodule