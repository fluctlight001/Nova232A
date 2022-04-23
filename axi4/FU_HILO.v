`include "lib/defines.vh"
module FU_HILO (
    input wire clk,
    input wire resetn,

    input wire ready,

    input wire [11:0] op,
    input wire [`INST_STATE_WD-1:0] inst_status,
    input wire [31:0] rdata1, 
    input wire [63:0] rdata2,

    output wire cb_we,
    output wire rf_we,
    output wire [31:0] wdata,
    output wire [31:0] extra_wdata
);
    reg [11:0] r_op;
    reg [31:0] r_rdata1;
    reg [63:0] r_rdata2;
    reg [`INST_STATE_WD-1:0] r_inst_status;
    wire busy;

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
        else if (busy) begin
            
        end    
        else begin
            r_op <= 12'b0;
            r_rdata1 <= 32'b0;
            r_rdata2 <= 32'b0;
            r_inst_status <= `INST_STATE_WD'b0;
        end
    end

    // mul & div
    wire inst_mfhi, inst_mflo,  inst_mthi,  inst_mtlo;
    wire inst_mult, inst_multu, inst_div,   inst_divu;

    // wire hi_we, lo_we;
    wire [31:0] hi_o, lo_o;
    wire op_mul, op_div;
    wire [63:0] mul_result, div_result;

    assign {
        inst_mfhi, inst_mflo, inst_mthi, inst_mtlo,
        inst_mult, inst_multu, inst_div, inst_divu
    } = r_inst_status[`OP];

    assign op_mul = inst_mult | inst_multu;
    assign op_div = inst_div | inst_divu;

    wire [31:0] src1, src2;
    assign src1 = r_rdata1;
    assign src2 = inst_mfhi ? r_rdata2[63:32] : r_rdata2[31:0];

    // MUL part
    mul u_mul(
    	.clk        (clk            ),
        .resetn     (resetn         ),
        .mul_signed (inst_mult      ),
        .ina        (src1           ),
        .inb        (src2           ),
        .result     (mul_result     )
    );

    // DIV part
    wire div_ready_i;
    reg stallreq_for_div;
    assign busy = stallreq_for_div;

    reg [31:0] div_opdata1_o;
    reg [31:0] div_opdata2_o;
    reg div_start_o;
    reg signed_div_o;

    div u_div(
    	.rst          (!resetn          ),
        .clk          (clk              ),
        .signed_div_i (signed_div_o     ),
        .opdata1_i    (div_opdata1_o    ),
        .opdata2_i    (div_opdata2_o    ),
        .start_i      (div_start_o      ),
        .annul_i      (1'b0             ),
        .result_o     (div_result       ),
        .ready_o      (div_ready_i      )
    );

    always @ (*) begin
        if (!resetn) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
        end
        else begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
            case ({inst_div,inst_divu})
                2'b10:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = src1;
                        div_opdata2_o = src2;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = src1;
                        div_opdata2_o = src2;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                2'b01:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = src1;
                        div_opdata2_o = src2;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = src1;
                        div_opdata2_o = src2;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                default:begin
                end
            endcase
        end
    end

    assign hi_we = inst_mthi | inst_div | inst_divu | inst_mult | inst_multu;
    assign lo_we = inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu;

    assign hi_o =   inst_mthi ? src1 : 
                    op_mul ? mul_result[63:32] :
                    op_div ? div_result[63:32] : 32'b0;
    
    assign lo_o =   inst_mtlo ? src1 :
                    op_mul ? mul_result[31:0] :
                    op_div ? div_result[31:0] : 32'b0;

    assign cb_we = ~busy & |r_inst_status[`OP];
    assign rf_we = ~busy & r_inst_status[`WE];
    assign waddr = r_inst_status[`ADDR];
    assign wdata = inst_mflo ? src2 : inst_mfhi ? src2 : inst_mtlo ? src1 : lo_o;
    assign extra_wdata = inst_mthi ? src1 : hi_o;
endmodule