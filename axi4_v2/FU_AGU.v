`include "lib/defines.vh"
module FU_AGU(
    input wire clk,
    input wire resetn,

    input wire ready,
    input wire dcache_miss,

    input wire [11:0] op,
    input wire [`INST_STATE_WD-1:0] inst_status,
    input wire [31:0] rdata1, rdata2,

    output wire cb_we,
    output wire rf_we,
    output wire store_en,
    output wire [3:0] store_sel,
    output wire [31:0] wdata,
    output wire [31:0] extra_wdata,

    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata
);
    wire cp0_en;
    wire cp0_wen;
    wire [4:0] cp0_addr;
    wire [31:0] cp0_wdata, cp0_rdata;

    reg [11:0] r_op;
    reg [31:0] r_rdata1, r_rdata2;
    reg [`INST_STATE_WD-1:0] r_inst_status_ex;

    always @ (posedge clk) begin
        if (!resetn) begin
            r_op <= 12'b0;
            r_rdata1 <= 32'b0;
            r_rdata2 <= 32'b0;
            r_inst_status_ex <= `INST_STATE_WD'b0;
        end
        else if (ready) begin
            r_op <= op;
            r_rdata1 <= rdata1;
            r_rdata2 <= rdata2;
            r_inst_status_ex <= inst_status;
        end    
        else if (dcache_miss) begin
            
        end
        else begin
            r_op <= 12'b0;
            r_rdata1 <= 32'b0;
            r_rdata2 <= 32'b0;
            r_inst_status_ex <= `INST_STATE_WD'b0;
        end
    end

    wire ex_mfc0, ex_mtc0, ex_lb, ex_lbu, ex_lh, ex_lhu, ex_lw, ex_sb, ex_sh, ex_sw;
    wire [1:0] ex_useless;
    assign {
        ex_useless,
        ex_mfc0, ex_mtc0,
        ex_lb, ex_lbu, ex_lh, ex_lhu, ex_lw, ex_sb, ex_sh, ex_sw
    } = r_op;

    wire [3:0] byte_sel;
    wire [3:0] data_sram_sel;
    wire [31:0] vaddr;
    wire [31:0] offset;

    assign offset = r_inst_status_ex[`IMM];
    assign vaddr = r_rdata1 + offset;

    decoder_2_4 u_decoder_2_4(
        .in  (vaddr[1:0]    ),
        .out (byte_sel      )
    );

    assign data_sram_en = ex_lb | ex_lbu | ex_lh | ex_lhu | ex_lw;
    assign data_sram_sel =  ex_sb | ex_lb | ex_lbu ? byte_sel :
                            ex_sh | ex_lh | ex_lhu ? {{2{byte_sel[2]}},{2{byte_sel[0]}}} :
                            ex_sw | ex_lw ? 4'b1111 : 4'b0000;
    assign data_sram_wen = 4'b0;
    assign data_sram_addr = ex_mtc0 | ex_mfc0 | ex_sb | ex_sh | ex_sw ? 32'b0 : vaddr;
    assign data_sram_wdata = 32'b0;
                                // {32{ex_sb}} & {4{r_rdata2[7:0]}} |
                                // {32{ex_sh}} & {2{r_rdata2[15:0]}} |
                                // {32{ex_sw}} & r_rdata2;

    assign cp0_en = ex_mfc0 | ex_mtc0;
    assign cp0_wen = ex_mtc0;
    assign cp0_addr = {5{ex_mfc0|ex_mtc0}} & r_inst_status_ex[`REG1];
    assign cp0_wdata = r_rdata2;





                                
    // mem state
    reg [`INST_STATE_WD-1:0] r_inst_status_mem;
    reg [3:0] r_data_sram_sel;
    reg [31:0] r_cp0_rdata;
    reg [31:0] r_vaddr;
    reg [31:0] r_data_sram_wdata;
    always @ (posedge clk) begin
        if (!resetn) begin
            r_inst_status_mem <= `INST_STATE_WD'b0;
            r_data_sram_sel <= 4'b0;
            r_cp0_rdata <= 32'b0;
            r_vaddr <= 32'b0;
            r_data_sram_wdata <= 32'b0;
        end
        else if (dcache_miss) begin
            
        end
        else begin
            r_inst_status_mem <= r_inst_status_ex;
            r_data_sram_sel <= data_sram_sel;
            r_cp0_rdata <= cp0_rdata;
            r_vaddr <= vaddr;
            r_data_sram_wdata <= {32{ex_sb}} & {4{r_rdata2[7:0]}} |
                                {32{ex_sh}} & {2{r_rdata2[15:0]}} |
                                {32{ex_sw}} & r_rdata2;
        end
    end

    wire [1:0] mem_useless;
    wire mem_mfc0, mem_mtc0, mem_lb, mem_lbu, mem_lh, mem_lhu, mem_lw, mem_sb, mem_sh, mem_sw;
    assign {
        mem_useless,
        mem_mfc0, mem_mtc0,
        mem_lb, mem_lbu, mem_lh, mem_lhu, mem_lw, mem_sb, mem_sh, mem_sw
    } = r_inst_status_mem[`OP];

    wire [7:0] b_data;
    wire [15:0] h_data;
    wire [31:0] w_data;
    wire [31:0] mem_result;

    assign b_data = r_data_sram_sel[3] ? data_sram_rdata[31:24] : 
                    r_data_sram_sel[2] ? data_sram_rdata[23:16] :
                    r_data_sram_sel[1] ? data_sram_rdata[15: 8] : 
                    r_data_sram_sel[0] ? data_sram_rdata[ 7: 0] : 8'b0;
    assign h_data = r_data_sram_sel[2] ? data_sram_rdata[31:16] :
                    r_data_sram_sel[0] ? data_sram_rdata[15: 0] : 16'b0;
    assign w_data = data_sram_rdata;

    assign mem_result = {32{mem_lb}}  & {{24{b_data[7]}},b_data} |
                        {32{mem_lbu}} & {{24{1'b0}},b_data} |
                        {32{mem_lh}}  & {{16{h_data[15]}},h_data} |
                        {32{mem_lhu}} & {{16{1'b0}},h_data} |
                        {32{mem_lw}}  & w_data;

    assign cb_we = dcache_miss ? 1'b0 : |r_inst_status_mem[`OP];
    assign rf_we = dcache_miss ? 1'b0 : r_inst_status_mem[`WE];
    assign store_en = mem_sb | mem_sh | mem_sw;
    assign store_sel = {4{mem_sb|mem_sh|mem_sw}} & r_data_sram_sel;
    assign wdata = (mem_sb|mem_sh|mem_sw) ? r_data_sram_wdata : mem_mfc0 ? r_cp0_rdata : mem_result;
    assign extra_wdata = r_vaddr;

    cp0_reg u_cp0_reg(
    	.clk       (clk       ),
        .resetn    (resetn    ),
        .cp0_en    (cp0_en    ),
        .cp0_wen   (cp0_wen   ),
        .cp0_addr  (cp0_addr  ),
        .cp0_wdata (cp0_wdata ),
        .cp0_rdata (cp0_rdata )
    );
    
endmodule