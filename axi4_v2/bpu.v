`include "lib/defines.vh"
module bpu(
    input wire clk,
    input wire resetn,
    input wire stall,

    input wire [31:0] current_pc1,
    input wire [31:0] current_pc2,

    input wire [`BR_WD-1:0] br_bus,
    input wire [31:0] delayslot_pc,

    output wire [`BR_WD-1:0] bp_bus,
    output wire [`BR_WD-1:0] bp_id_bus,
    output reg rrr_next_inst_invalid
    
);
    wire [7:0] hit_way, hit_way1, hit_way2;
    wire br_e;
    wire [31:0] br_target;
    reg bp_e;
    reg [31:0] bp_target;
    reg r_bp_e;
    reg [31:0] r_bp_target;
    reg bp_id_e;
    reg [31:0] bp_id_target;
    reg [7:0] valid;
    reg [31:0] branch_history_pc [7:0];
    reg [31:0] branch_target[7:0];
    wire next_inst_invalid;
    reg r_next_inst_invalid;
    reg rr_next_inst_invalid;

    assign {br_e, br_target} = br_bus;
    assign bp_bus = {bp_e, bp_target};
    assign bp_id_bus = {bp_id_e, bp_id_target};

    reg [6:0] lru;

    always @ (posedge clk) begin
        if (!resetn) begin
            lru <= 7'b0;
        end
        else if (hit_way[0] & ~hit_way[1]) begin
            lru[0] <= 1'b1;
            lru[4] <= 1'b1;
            lru[6] <= 1'b1;
        end
        else if (~hit_way[0] & hit_way[1]) begin
            lru[0] <= 1'b0;
            lru[4] <= 1'b1;
            lru[6] <= 1'b1;
        end
        else if (hit_way[2] & ~hit_way[3]) begin
            lru[1] <= 1'b1;
            lru[4] <= 1'b0;
            lru[6] <= 1'b1;
        end
        else if (~hit_way[2] & hit_way[3]) begin
            lru[1] <= 1'b0;
            lru[4] <= 1'b0;
            lru[6] <= 1'b1;
        end
        else if (hit_way[4] & ~hit_way[5]) begin
            lru[2] <= 1'b1;
            lru[5] <= 1'b1;
            lru[6] <= 1'b0;
        end
        else if (~hit_way[4] & hit_way[5]) begin
            lru[2] <= 1'b0;
            lru[5] <= 1'b1;
            lru[6] <= 1'b0;
        end
        else if (hit_way[6] & ~hit_way[7]) begin
            lru[3] <= 1'b1;
            lru[5] <= 1'b0;
            lru[6] <= 1'b0;
        end
        else if (~hit_way[6] & hit_way[7]) begin
            lru[3] <= 1'b0;
            lru[5] <= 1'b0;
            lru[6] <= 1'b0;
        end
        else if (br_e) begin
            lru <= {lru[3:0],lru[6:4]};    
        end
    end

    wire jump_err;
    assign jump_err = br_e & br_target == delayslot_pc + 4'd4;

    always @ (posedge clk) begin
        if (!resetn) begin
            valid <= 8'b0;
            branch_history_pc[0] <= 32'b0;
            branch_history_pc[1] <= 32'b0;
            branch_history_pc[2] <= 32'b0;
            branch_history_pc[3] <= 32'b0;
            branch_history_pc[4] <= 32'b0;
            branch_history_pc[5] <= 32'b0;
            branch_history_pc[6] <= 32'b0;
            branch_history_pc[7] <= 32'b0;
            branch_target[0] <= 32'b0;
            branch_target[1] <= 32'b0;
            branch_target[2] <= 32'b0;
            branch_target[3] <= 32'b0;
            branch_target[4] <= 32'b0;
            branch_target[5] <= 32'b0;
            branch_target[6] <= 32'b0;
            branch_target[7] <= 32'b0;
        end
        else if (~jump_err & br_e & ~lru[0] & ~lru[4] & ~lru[6]) begin
            valid[0] <= 1'b1;
            branch_history_pc[0] <= delayslot_pc;
            branch_target[0] <= br_target;
        end
        else if (~jump_err & br_e & lru[0] & ~lru[4] & ~lru[6]) begin
            valid[1] <= 1'b1;
            branch_history_pc[1] <= delayslot_pc;
            branch_target[1] <= br_target;
        end
        else if (~jump_err & br_e & ~lru[1] & lru[4] & ~lru[6]) begin
            valid[2] <= 1'b1;
            branch_history_pc[2] <= delayslot_pc;
            branch_target[2] <= br_target;
        end
        else if (~jump_err & br_e & lru[1] & lru[4] & ~lru[6]) begin
            valid[3] <= 1'b1;
            branch_history_pc[3] <= delayslot_pc;
            branch_target[3] <= br_target;
        end
        else if (~jump_err & br_e & ~lru[2] & ~lru[5] & lru[6]) begin
            valid[4] <= 1'b1;
            branch_history_pc[4] <= delayslot_pc;
            branch_target[4] <= br_target;
        end
        else if (~jump_err & br_e & lru[2] & ~lru[5] & lru[6]) begin
            valid[5] <= 1'b1;
            branch_history_pc[5] <= delayslot_pc;
            branch_target[5] <= br_target;
        end
        else if (~jump_err & br_e & ~lru[3] & lru[5] & lru[6]) begin
            valid[6] <= 1'b1;
            branch_history_pc[6] <= delayslot_pc;
            branch_target[6] <= br_target;
        end
        else if (~jump_err & br_e & lru[3] & lru[5] & lru[6]) begin
            valid[7] <= 1'b1;
            branch_history_pc[7] <= delayslot_pc;
            branch_target[7] <= br_target;
        end
    end

    assign hit_way1[0] = valid[0] & (branch_history_pc[0] == current_pc1);
    assign hit_way1[1] = valid[1] & (branch_history_pc[1] == current_pc1);
    assign hit_way1[2] = valid[2] & (branch_history_pc[2] == current_pc1);
    assign hit_way1[3] = valid[3] & (branch_history_pc[3] == current_pc1);
    assign hit_way1[4] = valid[4] & (branch_history_pc[4] == current_pc1);
    assign hit_way1[5] = valid[5] & (branch_history_pc[5] == current_pc1);
    assign hit_way1[6] = valid[6] & (branch_history_pc[6] == current_pc1);
    assign hit_way1[7] = valid[7] & (branch_history_pc[7] == current_pc1);
    assign hit_way2[0] = valid[0] & (branch_history_pc[0] == current_pc2);
    assign hit_way2[1] = valid[1] & (branch_history_pc[1] == current_pc2);
    assign hit_way2[2] = valid[2] & (branch_history_pc[2] == current_pc2);
    assign hit_way2[3] = valid[3] & (branch_history_pc[3] == current_pc2);
    assign hit_way2[4] = valid[4] & (branch_history_pc[4] == current_pc2);
    assign hit_way2[5] = valid[5] & (branch_history_pc[5] == current_pc2);
    assign hit_way2[6] = valid[6] & (branch_history_pc[6] == current_pc2);
    assign hit_way2[7] = valid[7] & (branch_history_pc[7] == current_pc2);
    assign hit_way[0] = hit_way1[0] | hit_way2[0];
    assign hit_way[1] = hit_way1[1] | hit_way2[1];
    assign hit_way[2] = hit_way1[2] | hit_way2[2];
    assign hit_way[3] = hit_way1[3] | hit_way2[3];
    assign hit_way[4] = hit_way1[4] | hit_way2[4];
    assign hit_way[5] = hit_way1[5] | hit_way2[5];
    assign hit_way[6] = hit_way1[6] | hit_way2[6];
    assign hit_way[7] = hit_way1[7] | hit_way2[7];

    assign next_inst_invalid = hit_way1[0] | hit_way1[1] | hit_way1[2] | hit_way1[3] | hit_way1[4] | hit_way1[5] | hit_way1[6] | hit_way1[7];

    wire bp_e_w;
    wire [31:0] bp_target_w;
    assign bp_e_w = hit_way[0] | hit_way[1] | hit_way[2] | hit_way[3] | hit_way[4] | hit_way[5] | hit_way[6] | hit_way[7];
    assign bp_target_w = hit_way[0] ? branch_target[0] 
                        : hit_way[1] ? branch_target[1] 
                        : hit_way[2] ? branch_target[2]
                        : hit_way[3] ? branch_target[3]
                        : hit_way[4] ? branch_target[4]
                        : hit_way[5] ? branch_target[5]
                        : hit_way[6] ? branch_target[6]
                        : hit_way[7] ? branch_target[7] : 32'b0;

    always @ (posedge clk) begin
        if (!resetn | br_e) begin
            bp_e <= 1'b0;
            bp_target <= 32'b0;
            r_next_inst_invalid <= 1'b0;
            r_bp_e <= 1'b0;
            r_bp_target <= 32'b0;
            rr_next_inst_invalid <= 1'b0;
            bp_id_e <= 1'b0;
            bp_id_target <= 32'b0;
            rrr_next_inst_invalid <= 1'b0;
        end
        else if (!stall) begin
            bp_e <= bp_e_w;
            bp_target <= bp_target_w;
            r_next_inst_invalid <= next_inst_invalid; 
            r_bp_e <= bp_e;
            r_bp_target <= bp_target;
            rr_next_inst_invalid <= r_next_inst_invalid;
            bp_id_e <= r_bp_e;
            bp_id_target <= r_bp_target;
            rrr_next_inst_invalid <= rr_next_inst_invalid;
        end
    end

endmodule