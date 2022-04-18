`include "lib/defines.vh"
module decoder (
    input wire clk,
    input wire resetn,

    input wire br_e,
    input wire stall,
    
    input wire [31:0] pc,
    input wire [31:0] inst_sram_rdata,
    
    output wire inst_valid,
    output wire [`ID_TO_SB_WD-1:0] id_to_sb_bus
);

    reg [31:0] pc_r, inst_sram_rdata_r;
    reg flag;
    reg [31:0] buf_pc, buf_inst;

    always @ (posedge clk) begin
        if (stall & ~flag) begin
            buf_pc <= pc;
            buf_inst <= inst_sram_rdata;
        end
    end
    always @ (posedge clk) begin
        if (!resetn) begin
            pc_r <= 32'b0;
            inst_sram_rdata_r <= 32'b0;
            flag <= 1'b0;
        end
        else if (br_e) begin
            pc_r <= 32'b0;
            inst_sram_rdata_r <= 32'b0;
            flag <= 1'b0;
        end
        else if (stall & ~flag) begin
            flag <= 1'b1;
        end
        else if (stall) begin
            
        end
        else if (flag) begin
            flag <= 1'b0;
            pc_r <= buf_pc;
            inst_sram_rdata_r <= buf_inst;
        end
        else begin
            pc_r <= pc;
            inst_sram_rdata_r <= inst_sram_rdata;
        end
    end

    wire [31:0] inst;
    assign inst = inst_sram_rdata_r;

    wire [5:0] opcode;
    wire [4:0] rs,rt,rd,sa;
    wire [5:0] func;
    wire [15:0] imm;
    wire [25:0] instr_index;
    wire [19:0] code;
    wire [4:0] base;
    wire [15:0] offset;
    wire [2:0] sel;

    assign opcode = inst[31:26];
    assign rs = inst[25:21];
    assign rt = inst[20:16];
    assign rd = inst[15:11];
    assign sa = inst[10:6];
    assign func = inst[5:0];
    assign imm = inst[15:0];
    assign instr_index = inst[25:0];
    assign code = inst[25:6];
    assign base = inst[25:21];
    assign offset = inst[15:0];
    assign sel = inst[2:0];

    wire [63:0] op_d, func_d;
    wire [31:0] rs_d, rt_d, rd_d, sa_d;

    decoder_6_64 u0_decoder_6_64(
        .in  (opcode    ),
        .out (op_d      )
    );
    decoder_6_64 u1_decoder_6_64(
        .in  (func      ),
        .out (func_d    )
    );
    decoder_5_32 u0_decoder_5_32(
        .in  (rs        ),
        .out (rs_d      )
    );
    decoder_5_32 u1_decoder_5_32(
        .in  (rt        ),
        .out (rt_d      )
    );
    decoder_5_32 u2_decoder_5_32(
        .in  (rd        ),
        .out (rd_d      )
    );
    decoder_5_32 u3_decoder_5_32(
        .in  (sa        ),
        .out (sa_d      )
    );

    wire inst_add,  inst_addi,  inst_addu,  inst_addiu;
    wire inst_sub,  inst_subu,  inst_slt,   inst_slti;
    wire inst_sltu, inst_sltiu, inst_div,   inst_divu;
    wire inst_mult, inst_multu, inst_and,   inst_andi;
    wire inst_lui,  inst_nor,   inst_or,    inst_ori;
    wire inst_xor,  inst_xori,  inst_sllv,  inst_sll;
    wire inst_srav, inst_sra,   inst_srlv,  inst_srl;
    wire inst_beq,  inst_bne,   inst_bgez,  inst_bgtz;
    wire inst_blez, inst_bltz,  inst_bgezal,inst_bltzal;
    wire inst_j,    inst_jal,   inst_jr,    inst_jalr;
    wire inst_mfhi, inst_mflo,  inst_mthi,  inst_mtlo;
    wire inst_break,    inst_syscall;
    wire inst_lb,   inst_lbu,   inst_lh,    inst_lhu,   inst_lw;
    wire inst_sb,   inst_sh,    inst_sw;
    wire inst_eret, inst_mfc0,  inst_mtc0;

    assign inst_add     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0000];
    assign inst_addi    = op_d[6'b00_1000];
    assign inst_addu    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0001];
    assign inst_addiu   = op_d[6'b00_1001];
    assign inst_sub     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0010];
    assign inst_subu    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0011];
    assign inst_slt     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_1010];
    assign inst_slti    = op_d[6'b00_1010];
    assign inst_sltu    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_1011];
    assign inst_sltiu   = op_d[6'b00_1011];
    assign inst_div     = op_d[6'b00_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_1010];
    assign inst_divu    = op_d[6'b00_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_1011];
    assign inst_mult    = op_d[6'b00_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_1000];
    assign inst_multu   = op_d[6'b00_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_1001];
    assign inst_and     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0100];
    assign inst_andi    = op_d[6'b00_1100];
    assign inst_lui     = op_d[6'b00_1111];
    assign inst_nor     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0111];
    assign inst_or      = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0101];
    assign inst_ori     = op_d[6'b00_1101];
    assign inst_xor     = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b10_0110];
    assign inst_xori    = op_d[6'b00_1110];
    assign inst_sllv    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b00_0100];
    assign inst_sll     = op_d[6'b00_0000] & rs_d[5'b0_0000] & func_d[6'b00_0000];
    assign inst_srav    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b00_0111];
    assign inst_sra     = op_d[6'b00_0000] & rs_d[5'b0_0000] & func_d[6'b00_0011];
    assign inst_srlv    = op_d[6'b00_0000] & sa_d[5'b0_0000] & func_d[6'b00_0110];
    assign inst_srl     = op_d[6'b00_0000] & rs_d[5'b0_0000] & func_d[6'b00_0010];
    assign inst_beq     = op_d[6'b00_0100];
    assign inst_bne     = op_d[6'b00_0101];
    assign inst_bgez    = op_d[6'b00_0001] & rt_d[5'b0_0001];
    assign inst_bgtz    = op_d[6'b00_0111] & rt_d[5'b0_0000];
    assign inst_blez    = op_d[6'b00_0110] & rt_d[5'b0_0000];
    assign inst_bltz    = op_d[6'b00_0001] & rt_d[5'b0_0000];
    assign inst_bgezal  = op_d[6'b00_0001] & rt_d[5'b1_0001];
    assign inst_bltzal  = op_d[6'b00_0001] & rt_d[5'b1_0000];
    assign inst_j       = op_d[6'b00_0010];
    assign inst_jal     = op_d[6'b00_0011];
    assign inst_jr      = op_d[6'b00_0000] & rt_d[5'b0_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b00_1000];
    assign inst_jalr    = op_d[6'b00_0000] & rt_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b00_1001];
    assign inst_mfhi    = op_d[6'b00_0000] & rs_d[5'b0_0000] & rt_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_0000];
    assign inst_mflo    = op_d[6'b00_0000] & rs_d[5'b0_0000] & rt_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_0010];
    assign inst_mthi    = op_d[6'b00_0000] & rt_d[5'b0_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_0001];
    assign inst_mtlo    = op_d[6'b00_0000] & rt_d[5'b0_0000] & rd_d[5'b0_0000] & sa_d[5'b0_0000] & func_d[6'b01_0011];
    assign inst_break   = op_d[6'b00_0000] & func_d[6'b00_1101];
    assign inst_syscall = op_d[6'b00_0000] & func_d[6'b00_1100];
    assign inst_lb      = op_d[6'b10_0000];
    assign inst_lbu     = op_d[6'b10_0100];
    assign inst_lh      = op_d[6'b10_0001];
    assign inst_lhu     = op_d[6'b10_0101];
    assign inst_lw      = op_d[6'b10_0011];
    assign inst_sb      = op_d[6'b10_1000];
    assign inst_sh      = op_d[6'b10_1001];
    assign inst_sw      = op_d[6'b10_1011];
    assign inst_mfc0    = op_d[6'b01_0000] & rs_d[5'b0_0000] & sa_d[5'b0_0000] & (inst[5:3]==3'b000);
    assign inst_mtc0    = op_d[6'b01_0000] & rs_d[5'b0_0100] & sa_d[5'b0_0000] & (inst[5:3]==3'b000);

    wire op_add, op_sub, op_slt, op_sltu;
    wire op_and, op_nor, op_or, op_xor;
    wire op_sll, op_srl, op_sra, op_lui;

    assign op_add = inst_add | inst_addi | inst_addiu | inst_addu;
    assign op_sub = inst_subu | inst_sub;
    assign op_slt = inst_slt | inst_slti;
    assign op_sltu = inst_sltu | inst_sltiu;
    assign op_and = inst_and | inst_andi;
    assign op_nor = inst_nor;
    assign op_or = inst_ori | inst_or;
    assign op_xor = inst_xor | inst_xori;
    assign op_sll = inst_sll | inst_sllv;
    assign op_srl = inst_srl | inst_srlv;
    assign op_sra = inst_sra | inst_srav;
    assign op_lui = inst_lui;


    wire [11:0] alu_op, hilo_op, mem_op, br_op;
    assign br_op = {
        inst_beq,   inst_bne,   inst_bgez,  inst_bgtz,
        inst_blez,  inst_bltz,  inst_bgezal,inst_bltzal,
        inst_j,     inst_jal,   inst_jr,    inst_jalr
    };

    assign alu_op = {
        op_add, op_sub, op_slt, op_sltu,
        op_and, op_nor, op_or, op_xor,
        op_sll, op_srl, op_sra, op_lui
    };
    
    assign hilo_op = {
        4'b0,
        inst_mfhi, inst_mflo, inst_mthi, inst_mtlo,
        inst_mult, inst_multu, inst_div, inst_divu
    };

    assign mem_op = {
        4'b0,
        inst_lb, inst_lbu, inst_lh, inst_lhu, 
        inst_lw, inst_sb, inst_sh, inst_sw
    };

    wire rf_we;
    wire [4:0] rf_waddr;
    wire [3:0] sel_rf_dst;
    wire [4:0] sel_alu_imm;
    wire [31:0] imm_o;

    // // regfile store enable
    assign rf_we    = inst_ori | inst_lui | inst_addiu | inst_subu | inst_jal | inst_addu | inst_sll | inst_or 
                    | inst_lw | inst_xor | inst_sltu | inst_slt | inst_slti | inst_sltiu | inst_add | inst_addi
                    | inst_sub | inst_and | inst_andi | inst_nor | inst_xori | inst_sllv | inst_sra | inst_srav
                    | inst_srl | inst_srlv | inst_bltzal | inst_bgezal | inst_jalr | inst_mflo | inst_mfhi
                    | inst_lh | inst_lhu | inst_lb | inst_lbu 
                    | inst_div | inst_divu | inst_mult | inst_multu | inst_mthi | inst_mtlo;

    // store in [rd]
    assign sel_rf_dst[0]    = inst_addu | inst_subu | inst_sll | inst_or | inst_xor | inst_sltu | inst_slt | inst_add
                            | inst_sub | inst_and | inst_nor | inst_sllv | inst_sra | inst_srav | inst_srl | inst_srlv
                            | inst_mflo | inst_mfhi;
    // store in [rt] 
    assign sel_rf_dst[1]    = inst_ori | inst_lui | inst_addiu | inst_lw | inst_slti | inst_sltiu | inst_addi | inst_andi
                            | inst_xori | inst_lh | inst_lhu | inst_lb | inst_lbu;
    // store in [31]
    assign sel_rf_dst[2] = inst_jal | inst_bltzal | inst_bgezal | inst_jalr;
    // store in [hilo]
    assign sel_rf_dst[3] = inst_div | inst_divu | inst_mult | inst_multu | inst_mthi | inst_mtlo;

    // sel for regfile address
    assign rf_waddr = {6{sel_rf_dst[0]}} & rd 
                    | {6{sel_rf_dst[1]}} & rt
                    | {6{sel_rf_dst[2]}} & 6'd31
                    | {6{sel_rf_dst[3]}} & 6'd32;
                //  | {5{~rf_we}} & 32'b0;  //when inst dont want write back , write the result to reg[0];

    // sa_zero_extend to reg1
    assign sel_alu_imm[0] = inst_sll | inst_sra | inst_srl;
    // imm_sign_extend to reg2
    assign sel_alu_imm[1] = inst_addi | inst_addiu | inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu 
                            | inst_sw | inst_sh | inst_sb | inst_lui | inst_slti | inst_sltiu ;
    // imm_zero_extend to reg2
    assign sel_alu_imm[2] = inst_ori | inst_andi | inst_xori;
    // offset_sign_extend to bru
    assign sel_alu_imm[3] = inst_beq | inst_bne | inst_bgez | inst_bgtz 
                            | inst_blez | inst_bltz | inst_bltzal | inst_bgezal;
    // instr_index_extend to bru
    assign sel_alu_imm[4] = inst_j | inst_jal;

    // sel imm for fu
    assign imm_o = {32{sel_alu_imm[0]}} & {27'b0,inst[10:6]}                // sa_zero_extend
                 | {32{sel_alu_imm[1]}} & {{16{inst[15]}}, inst[15:0]}      // imm_sign_extend
                 | {32{sel_alu_imm[2]}} & {16'b0, inst[15:0]}               // imm_zero_extend
                 | {32{sel_alu_imm[3]}} & {{14{inst[15]}},inst[15:0],2'b0}  // offset_sign_extend
                 | {32{sel_alu_imm[4]}} & {pc_r[31:28],instr_index,2'b0};   // instr_index_extend
//  output
    wire except_sw;
    wire [31:0] excepttype;
    wire [11:0] op;
    wire [2:0] fu;
    wire [7:0] fu_sel;
    wire [5:0] reg1, reg2, reg3;
    wire r1_val, r2_val;
    wire r1_rdy, r2_rdy;
    // wire rf_we;
    // wire [31:0] imm_o;
    wire sel_src1, sel_src2; 

    assign except_sw = inst_add;
    assign excepttype = 32'b0;
    assign op = alu_op | hilo_op | mem_op | br_op;
    assign fu   = {3{fu_sel[0]}} & 3'd0
                | {3{fu_sel[2]}} & 3'd2
                | {3{fu_sel[3]}} & 3'd3
                | {3{fu_sel[4]}} & 3'd4;
    assign fu_sel[0] = inst_addiu;
    assign fu_sel[2] = inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | inst_bgezal | inst_j | inst_jal | inst_jr | inst_jalr;
    assign fu_sel[3] = inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw;
    assign fu_sel[4] = inst_mfhi | inst_mflo | inst_mthi | inst_mtlo | inst_mult | inst_multu | inst_div | inst_divu;
    assign reg1 = rs;
    assign reg2 = rt;
    assign reg3 = rf_waddr;
    assign r1_val = inst_add | inst_addiu | inst_addu | inst_subu | inst_ori | inst_or | inst_sw | inst_lw 
                    | inst_xor | inst_sltu | inst_slt | inst_slti | inst_sltiu | inst_addi | inst_sub 
                    | inst_and | inst_andi | inst_nor | inst_xori | inst_sllv | inst_srav | inst_srlv
                    | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_sb | inst_sh | inst_jr | inst_jalr
                    | inst_beq | inst_bne |inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal
                    | inst_mthi | inst_mtlo | inst_mult | inst_multu | inst_div | inst_divu;
    assign r2_val = inst_add | inst_addu | inst_subu | inst_sll | inst_or | inst_xor | inst_sltu | inst_slt
                    | inst_sub | inst_and | inst_nor | inst_sllv | inst_sra | inst_srav | inst_srl | inst_srlv
                    | inst_beq | inst_bne | inst_sb | inst_sh | inst_sw | inst_mult | inst_multu | inst_div | inst_divu;
    // reg1 useless or reg1 use imm
    assign r1_rdy = ~r1_val;
    // reg2 useless or reg2 use imm
    assign r2_rdy = ~r2_val;
    // 0 -> reg1 | 1 -> imm
    assign sel_src1 = sel_alu_imm[0];
    // 0 -> reg2 | 1 -> imm
    assign sel_src2 = sel_alu_imm[1] | sel_alu_imm[2]; 

    assign id_to_sb_bus = {
        except_sw,  // 136
        excepttype, // 135:104
        op,         // 103:92
        fu,         // 91:89
        reg1,       // 88:83
        r1_val,     // 82
        r1_rdy,     // 81
        reg2,       // 80:75
        r2_val,     // 74
        r2_rdy,     // 73
        reg3,       // 72:67
        rf_we,      // 66
        imm_o,      // 65:34
        sel_src1,   // 33
        sel_src2,   // 32
        pc_r        // 31:0
    };

    assign inst_valid = (|pc_r) & 
                        (inst_add | inst_addi | inst_addu | inst_addiu
                        | inst_sub | inst_subu | inst_slt | inst_slti 
                        | inst_sltu | inst_sltiu | inst_div | inst_divu
                        | inst_mult | inst_multu | inst_and | inst_andi 
                        | inst_lui | inst_nor | inst_or | inst_ori 
                        | inst_xor | inst_xori | inst_sll | inst_sllv
                        | inst_sra | inst_srav | inst_srl | inst_srlv
                        | inst_beq | inst_bne | inst_bgez | inst_bgtz
                        | inst_blez | inst_bltz | inst_bltzal | inst_bgezal
                        | inst_j | inst_jal | inst_jr | inst_jalr 
                        | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo 
                        | inst_lb | inst_lbu | inst_lh | inst_lhu 
                        | inst_lw | inst_sb | inst_sh | inst_sw 
                        // | inst_break | inst_syscall | inst_eret 
                        // | inst_mfc0 | inst_mtc0
                        );
    


endmodule