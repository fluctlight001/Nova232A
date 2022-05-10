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
    wire [1:0] hit_way, hit_way1, hit_way2;
    wire br_e;
    wire [31:0] br_target;
    wire bp_e;
    wire [31:0] bp_target;
    reg [1:0] valid;
    reg [31:0] branch_history_pc [1:0];
    reg [31:0] branch_target[1:0];
    
    assign {br_e, br_target} = br_bus;
    assign bp_bus = {bp_e, bp_target};

    reg lru;

    always @ (posedge clk) begin
        if (!resetn) begin
            lru <= 1'b0;
        end
        else if (hit_way[0]) begin
            lru <= 1'b1;
        end
        else if (hit_way[1]) begin
            lru <= 1'b0;
        end
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            valid <= 1'b0;
            branch_history_pc[0] <= 32'b0;
            branch_history_pc[1] <= 32'b0;
            branch_target[0] <= 32'b0;
            branch_target[1] <= 32'b0;
        end
        else if (br_e & ~lru) begin
            valid[0] <= 1'b1;
            branch_history_pc[0] <= delayslot_pc;
            branch_target[0] <= br_target;
        end
        else if (br_e & lru) begin
            valid[1] <= 1'b1;
            branch_history_pc[1] <= delayslot_pc;
            branch_target[1] <= br_target;
        end
    end

    assign hit_way1[0] = valid[0] & (branch_history_pc[0] == current_pc1);
    assign hit_way1[1] = valid[1] & (branch_history_pc[1] == current_pc1);
    assign hit_way2[0] = valid[0] & (branch_history_pc[0] == current_pc2);
    assign hit_way2[1] = valid[1] & (branch_history_pc[1] == current_pc2);

    assign hit_way[0] = hit_way1[0] | hit_way2[0];
    assign hit_way[1] = hit_way1[1] | hit_way2[1];

    assign next_inst_invalid = hit_way1[0] | hit_way1[1];

    assign bp_e = hit_way[0] | hit_way[1];
    assign bp_target = hit_way[0] ? branch_target[0] 
                    : hit_way[1] ? branch_target[1] : 32'b0;



endmodule