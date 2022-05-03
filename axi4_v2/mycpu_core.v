`include "lib/defines.vh"
module mycpu_core(
    input wire clk,
    input wire resetn,
    input wire [5:0] int,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input wire [63:0] inst_sram_rdata,

    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata,

    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);
    wire stall;
    wire [31:0] pc;
    wire [`BR_WD-1:0] br_bus;
    wire inst1_valid, inst2_valid;
    wire [`ID_TO_SB_WD-1:0] inst1_bus, inst2_bus;
    wire [31:0] inst_sram_addr_v, data_sram_addr_v;
    wire stallreq;
    assign stall = stallreq;

    mmu u0_mmu(
    	.addr_i (inst_sram_addr_v ),
        .addr_o (inst_sram_addr   )
    );

    mmu u1_mmu(
    	.addr_i (data_sram_addr_v ),
        .addr_o (data_sram_addr   )
    );

    IF u_IF(
    	.clk             (clk             ),
        .resetn          (resetn          ),
        .stall           (stall           ),
        .pc_reg          (pc              ),
        .br_bus          (br_bus          ),
        .inst_sram_en    (inst_sram_en    ),
        .inst_sram_wen   (inst_sram_wen   ),
        .inst_sram_addr  (inst_sram_addr_v),
        .inst_sram_wdata (inst_sram_wdata )
    );
    
    ID u_ID(
    	.clk             (clk             ),
        .resetn          (resetn          ),
        .br_bus          (br_bus          ),
        .stall           (stall           ),
        .pc              (pc              ),
        .inst_sram_rdata (inst_sram_rdata ),
        .inst1_valid     (inst1_valid     ),
        .inst1           (inst1_bus       ),
        .inst2_valid     (inst2_valid     ),
        .inst2           (inst2_bus       )
    );
    

    scoreboard u_scoreboard(
    	.clk               (clk               ),
        .resetn            (resetn            ),
        .stallreq          (stallreq          ),
        .inst1_valid       (inst1_valid       ),
        .inst2_valid       (inst2_valid       ),
        .inst1             (inst1_bus         ),
        .inst2             (inst2_bus         ),
        .br_bus            (br_bus            ),
        .data_sram_en      (data_sram_en      ),
        .data_sram_wen     (data_sram_wen     ),
        .data_sram_addr    (data_sram_addr_v  ),
        .data_sram_wdata   (data_sram_wdata   ),
        .data_sram_rdata   (data_sram_rdata   ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    
    
    
    
endmodule