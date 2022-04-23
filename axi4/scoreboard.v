`include "lib/defines.vh"
module scoreboard(
    input wire clk,
    input wire resetn,

    input wire dcache_miss,
    output wire stallreq,

    input wire inst1_valid,
    input wire [`ID_TO_SB_WD-1:0] inst1,

    output wire [`BR_WD-1:0] br_bus,

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

    wire flush;
    reg [`INST_STATE_WD-1:0] inst_status [15:0];
    reg [15:0] valid_inst, dispatch, issue, execute, writeback;
    reg [2:0] reg_status [33:0];
    reg [7:0] busy;
    reg [11:0] op [7:0];
    reg [5:0] r [7:0];
    reg [5:0] r1 [7:0];
    reg [5:0] r2 [7:0];
    reg [2:0] t1 [7:0]; 
    reg [2:0] t2 [7:0];
    reg [31:0] cb [15:0];
    reg [31:0] cb_extra [15:0];
    reg [15:0] rf_we_r;
    reg [15:0] br_e_r;
    
    wire [7:0] cb_we;
    wire [7:0] rf_we;
    wire br_e;
    wire [31:0] wdata [7:0];
    wire [31:0] extra_wdata [7:0];
    wire dispatch_ok;
    wire [7:0] wb_ok;
    

    reg [4:0] wptr, rptr;
    reg [3:0] dptr;
    reg [3:0] iptr [7:0];
    wire [4:0] wptr_next;
    reg [4:0] rptr_next;
    wire [3:0] dptr_next;
    wire [7:0] fu_rdy;

    wire [3:0] retire_en;

    reg full;
    wire full_next;
    wire [4:0] rest;
    assign rest = wptr_next[4] == rptr_next[4] ? (wptr_next - rptr_next) : ({1'b1,wptr_next[3:0]} - {1'b0,rptr_next[3:0]});
    assign full_next = rest > 15 ? 1 : 0;
    assign stallreq = full_next;
    // assign flush = br_e;
    

    always @ (posedge clk) begin
        if (!resetn) begin
            full <= 1'b0;
        end
        else begin
            full <= full_next;
        end
    end

    assign wptr_next = wptr + 1;
    always @ (posedge clk) begin
        if (!resetn) begin
            wptr <= 0;
        end
        else if (br_bus[32]) begin
            wptr <= rptr + 2;
        end
        else if (!full & !br_bus[32] & inst1_valid) begin
            wptr <= wptr_next;
        end
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            rptr <= 0;
        end
        else begin
            rptr <= rptr_next;
        end
    end
    //  retire // commit
    wire [3:0] raddr;
    assign raddr = rptr[3:0];
    assign retire_en[0] = valid_inst[raddr] & writeback[raddr];
    assign retire_en[1] = 1'b0; // inst_status[rptr+1][`CPLT] & retire_en[0];
    assign retire_en[2] = 1'b0; // inst_status[rptr+2][`CPLT] & retire_en[1];
    assign retire_en[3] = 1'b0; // inst_status[rptr+3][`CPLT] & retire_en[2];
    
    always @ (*) begin
        case (retire_en)
            4'b0001:rptr_next = rptr + 1;
            4'b0011:rptr_next = rptr + 2;
            4'b0111:rptr_next = rptr + 3;
            4'b1111:rptr_next = rptr + 4;
            default:rptr_next = rptr;
        endcase
    end

    assign dispatch_ok = valid_inst[dptr]&~dispatch[dptr]&~busy[inst_status[dptr][`FU]]&reg_status[inst_status[dptr][`REG3]]==`NULL&(!br_bus[32]|dptr==raddr+1'b1);
    always @ (posedge clk) begin
        if (!resetn) begin
            dptr <= 0;
        end
        else if (br_bus[32]) begin
            dptr <= rptr[3:0] + 1'd1;
        end
        else if (dispatch[dptr]) begin
            dptr <= dptr + 1'b1;
        end
        else if (dispatch_ok) begin
            dptr <= dptr + 1'b1;
        end
    end

    wire [3:0] waddr = wptr[3:0];
    always @ (posedge clk) begin
        if (!resetn) begin
            inst_status[ 0] <= `INST_STATE_WD'b0;
            inst_status[ 1] <= `INST_STATE_WD'b0;
            inst_status[ 2] <= `INST_STATE_WD'b0;
            inst_status[ 3] <= `INST_STATE_WD'b0;
            inst_status[ 4] <= `INST_STATE_WD'b0;
            inst_status[ 5] <= `INST_STATE_WD'b0;
            inst_status[ 6] <= `INST_STATE_WD'b0;
            inst_status[ 7] <= `INST_STATE_WD'b0;
            inst_status[ 8] <= `INST_STATE_WD'b0;
            inst_status[ 9] <= `INST_STATE_WD'b0;
            inst_status[10] <= `INST_STATE_WD'b0;
            inst_status[11] <= `INST_STATE_WD'b0;
            inst_status[12] <= `INST_STATE_WD'b0;
            inst_status[13] <= `INST_STATE_WD'b0;
            inst_status[14] <= `INST_STATE_WD'b0;
            inst_status[15] <= `INST_STATE_WD'b0;
            valid_inst <= 16'b0;
            dispatch <= 16'b0;
            issue <= 16'b0;
            execute <= 16'b0;
            writeback <= 16'b0;
        end
        else begin
            if (!full & !br_bus[32] & inst1_valid) begin
                valid_inst[waddr] <= 1'b1;
                dispatch[waddr] <= 1'b0;
                issue[waddr] <= 1'b0;
                execute[waddr] <= 1'b0;
                writeback[waddr] <= 1'b0;
                inst_status[waddr] <= {wptr, inst1};
            end
            else if (br_bus[32]) begin
                valid_inst <= 16'b0 ;
                valid_inst[raddr+1'b1] <= 1'b1;
                dispatch[raddr+2'd2] <= 1'b0;
                issue[raddr+2'd2] <= 1'b0;
                execute[raddr+2'd2] <= 1'b0;
                writeback[raddr+2'd2] <= 1'b0;
                inst_status[raddr+2'd2] <= `INST_STATE_WD'b0;
            end
            if (dispatch_ok) begin
                dispatch[dptr] <= 1'b1;
            end
            // if (valid_inst[iptr[0]] & fu_rdy[0]) issue[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[0]] & fu_rdy[0] & dispatch[iptr[0]]) issue[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[1]] & fu_rdy[1] & dispatch[iptr[1]]) issue[iptr[1]] <= 1'b1;
            if (valid_inst[iptr[2]] & fu_rdy[2] & dispatch[iptr[2]]) issue[iptr[2]] <= 1'b1;
            if (valid_inst[iptr[3]] & fu_rdy[3] & dispatch[iptr[3]]) issue[iptr[3]] <= 1'b1;
            if (valid_inst[iptr[4]] & fu_rdy[4] & dispatch[iptr[4]]) issue[iptr[4]] <= 1'b1;
            if (valid_inst[iptr[5]] & fu_rdy[5] & dispatch[iptr[5]]) issue[iptr[5]] <= 1'b1;
            if (valid_inst[iptr[6]] & fu_rdy[6] & dispatch[iptr[6]]) issue[iptr[6]] <= 1'b1;
            if (valid_inst[iptr[7]] & fu_rdy[7] & dispatch[iptr[7]]) issue[iptr[7]] <= 1'b1;

            // if (valid_inst[iptr[0]] & cb_we[0]) execute[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[0]] & cb_we[0] & issue[iptr[0]]) execute[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[1]] & cb_we[1] & issue[iptr[1]]) execute[iptr[1]] <= 1'b1;
            if (valid_inst[iptr[2]] & cb_we[2] & issue[iptr[2]]) execute[iptr[2]] <= 1'b1;
            if (valid_inst[iptr[3]] & cb_we[3] & issue[iptr[3]]) execute[iptr[3]] <= 1'b1;
            if (valid_inst[iptr[4]] & cb_we[4] & issue[iptr[4]]) execute[iptr[4]] <= 1'b1;
            if (valid_inst[iptr[5]] & cb_we[5] & issue[iptr[5]]) execute[iptr[5]] <= 1'b1;
            if (valid_inst[iptr[6]] & cb_we[6] & issue[iptr[6]]) execute[iptr[6]] <= 1'b1;
            if (valid_inst[iptr[7]] & cb_we[7] & issue[iptr[7]]) execute[iptr[7]] <= 1'b1;

            // if (valid_inst[iptr[0]] & wb_ok[0]) writeback[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[0]] & wb_ok[0] & execute[iptr[0]]) writeback[iptr[0]] <= 1'b1;
            if (valid_inst[iptr[1]] & wb_ok[1] & execute[iptr[1]]) writeback[iptr[1]] <= 1'b1;
            if (valid_inst[iptr[2]] & wb_ok[2] & execute[iptr[2]]) writeback[iptr[2]] <= 1'b1;
            if (valid_inst[iptr[3]] & wb_ok[3] & execute[iptr[3]]) writeback[iptr[3]] <= 1'b1;
            if (valid_inst[iptr[4]] & wb_ok[4] & execute[iptr[4]]) writeback[iptr[4]] <= 1'b1;
            if (valid_inst[iptr[5]] & wb_ok[5] & execute[iptr[5]]) writeback[iptr[5]] <= 1'b1;
            if (valid_inst[iptr[6]] & wb_ok[6] & execute[iptr[6]]) writeback[iptr[6]] <= 1'b1;
            if (valid_inst[iptr[7]] & wb_ok[7] & execute[iptr[7]]) writeback[iptr[7]] <= 1'b1;

            if (retire_en[0]) begin
                valid_inst[raddr] <= 1'b0;
                dispatch[raddr] <= 1'b0;
                issue[raddr] <= 1'b0;
                execute[raddr] <= 1'b0;
                writeback[raddr] <= 1'b0;
                inst_status[raddr] <= `INST_STATE_WD'b0;
            end 
        end
    end

    wire [2:0] fu_ptr;
    wire [2:0] ds_ptr;
    assign fu_ptr = inst_status[dptr][`FU];
    assign ds_ptr = inst_status[raddr+1'd1][`FU];
    always @ (posedge clk) begin
        if (!resetn) begin
            {busy[0],op[0],r[0],r1[0],r2[0],t1[0],t2[0]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[1],op[1],r[1],r1[1],r2[1],t1[1],t2[1]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[2],op[2],r[2],r1[2],r2[2],t1[2],t2[2]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[3],op[3],r[3],r1[3],r2[3],t1[3],t2[3]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[4],op[4],r[4],r1[4],r2[4],t1[4],t2[4]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[5],op[5],r[5],r1[5],r2[5],t1[5],t2[5]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[6],op[6],r[6],r1[6],r2[6],t1[6],t2[6]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[7],op[7],r[7],r1[7],r2[7],t1[7],t2[7]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            iptr[0] <= 0; 
            iptr[1] <= 0;
            iptr[2] <= 0;
            iptr[3] <= 0;
            iptr[4] <= 0; 
            iptr[5] <= 0;
            iptr[6] <= 0;
            iptr[7] <= 0;
        end
        else if (br_bus[32]) begin
            {busy[0],op[0],r[0],r1[0],r2[0],t1[0],t2[0]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[1],op[1],r[1],r1[1],r2[1],t1[1],t2[1]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[2],op[2],r[2],r1[2],r2[2],t1[2],t2[2]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[3],op[3],r[3],r1[3],r2[3],t1[3],t2[3]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[4],op[4],r[4],r1[4],r2[4],t1[4],t2[4]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[5],op[5],r[5],r1[5],r2[5],t1[5],t2[5]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[6],op[6],r[6],r1[6],r2[6],t1[6],t2[6]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            {busy[7],op[7],r[7],r1[7],r2[7],t1[7],t2[7]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
            iptr[0] <= 0; 
            iptr[1] <= 0;
            iptr[2] <= 0;
            iptr[3] <= 0;
            iptr[4] <= 0; 
            iptr[5] <= 0;
            iptr[6] <= 0;
            iptr[7] <= 0;
            {busy[ds_ptr],op[ds_ptr],r[ds_ptr],r1[ds_ptr],r2[ds_ptr],t1[ds_ptr],t2[ds_ptr]} <= {busy[ds_ptr],op[ds_ptr],r[ds_ptr],r1[ds_ptr],r2[ds_ptr],t1[ds_ptr],t2[ds_ptr]};
            iptr[ds_ptr] <= iptr[ds_ptr];
            if (fu_ptr == ds_ptr) begin
                if (dispatch_ok) begin
                    iptr[fu_ptr] <= inst_status[dptr][`ADDR];
                    busy[fu_ptr] <= 1'b1;
                    op[fu_ptr] <= inst_status[dptr][`OP];
                    r[fu_ptr] <= inst_status[dptr][`REG3];
                    r1[fu_ptr] <= inst_status[dptr][`R1VAL] ? inst_status[dptr][`REG1] : 6'b111111;
                    r2[fu_ptr] <= inst_status[dptr][`R2VAL] ? inst_status[dptr][`REG2] : 6'b111111;
                    t1[fu_ptr] <= inst_status[dptr][`R1VAL] ? (valid_inst[raddr] & writeback[raddr] & inst_status[dptr][`REG1]==inst_status[raddr][`REG3] ? `NULL : reg_status[inst_status[dptr][`REG1]]) : `NULL;
                    t2[fu_ptr] <= inst_status[dptr][`R2VAL] ? (valid_inst[raddr] & writeback[raddr] & inst_status[dptr][`REG2]==inst_status[raddr][`REG3] ? `NULL : reg_status[inst_status[dptr][`REG2]]) : `NULL;
                end
            end
        end
        else begin
            if (valid_inst[iptr[0]] & writeback[iptr[0]] & iptr[0]==raddr & retire_en[0] & busy[0]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t2[1] <= t2[1] == `ALU1 ? `NULL : t2[1];
                t1[2] <= t1[2] == `ALU1 ? `NULL : t1[2];
                t2[2] <= t2[2] == `ALU1 ? `NULL : t2[2];
                t1[3] <= t1[3] == `ALU1 ? `NULL : t1[3];
                t2[3] <= t2[3] == `ALU1 ? `NULL : t2[3];
                t1[4] <= t1[4] == `ALU1 ? `NULL : t1[4];
                t2[4] <= t2[4] == `ALU1 ? `NULL : t2[4];
                t1[5] <= t1[5] == `ALU1 ? `NULL : t1[5];
                t2[5] <= t2[5] == `ALU1 ? `NULL : t2[5];
                t1[6] <= t1[6] == `ALU1 ? `NULL : t1[6];
                t2[6] <= t2[6] == `ALU1 ? `NULL : t2[6];
                t1[7] <= t1[7] == `ALU1 ? `NULL : t1[7];
                t2[7] <= t2[7] == `ALU1 ? `NULL : t2[7];
                {busy[0],op[0],r[0],r1[0],r2[0],t1[0],t2[0]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[0] <= 0;
            end
            else if (valid_inst[iptr[1]] & writeback[iptr[1]] & iptr[1]==raddr & retire_en[0] & busy[1]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `ALU2 ? `NULL : t1[0];
                t2[0] <= t2[0] == `ALU2 ? `NULL : t2[0];
                t1[2] <= t1[2] == `ALU2 ? `NULL : t1[2];
                t2[2] <= t2[2] == `ALU2 ? `NULL : t2[2];
                t1[3] <= t1[3] == `ALU2 ? `NULL : t1[3];
                t2[3] <= t2[3] == `ALU2 ? `NULL : t2[3];
                t1[4] <= t1[4] == `ALU2 ? `NULL : t1[4];
                t2[4] <= t2[4] == `ALU2 ? `NULL : t2[4];
                t1[5] <= t1[5] == `ALU2 ? `NULL : t1[5];
                t2[5] <= t2[5] == `ALU2 ? `NULL : t2[5];
                t1[6] <= t1[6] == `ALU2 ? `NULL : t1[6];
                t2[6] <= t2[6] == `ALU2 ? `NULL : t2[6];
                t1[7] <= t1[7] == `ALU2 ? `NULL : t1[7];
                t2[7] <= t2[7] == `ALU2 ? `NULL : t2[7];
                {busy[1],op[1],r[1],r1[1],r2[1],t1[1],t2[1]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[1] <= 0;
            end
            else if (valid_inst[iptr[2]] & writeback[iptr[2]] & iptr[2]==raddr & retire_en[0] & busy[2]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `BRU ? `NULL : t1[0];
                t2[0] <= t2[0] == `BRU ? `NULL : t2[0];
                t1[1] <= t1[1] == `BRU ? `NULL : t1[1];
                t2[1] <= t2[1] == `BRU ? `NULL : t2[1];
                t1[3] <= t1[3] == `BRU ? `NULL : t1[3];
                t2[3] <= t2[3] == `BRU ? `NULL : t2[3];
                t1[4] <= t1[4] == `BRU ? `NULL : t1[4];
                t2[4] <= t2[4] == `BRU ? `NULL : t2[4];
                t1[5] <= t1[5] == `BRU ? `NULL : t1[5];
                t2[5] <= t2[5] == `BRU ? `NULL : t2[5];
                t1[6] <= t1[6] == `BRU ? `NULL : t1[6];
                t2[6] <= t2[6] == `BRU ? `NULL : t2[6];
                t1[7] <= t1[7] == `BRU ? `NULL : t1[7];
                t2[7] <= t2[7] == `BRU ? `NULL : t2[7];
                {busy[2],op[2],r[2],r1[2],r2[2],t1[2],t2[2]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[2] <= 0;
            end
            else if (valid_inst[iptr[3]] & writeback[iptr[3]] & iptr[3]==raddr & retire_en[0] & busy[3]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `AGU ? `NULL : t1[0];
                t2[0] <= t2[0] == `AGU ? `NULL : t2[0];
                t1[1] <= t1[1] == `AGU ? `NULL : t1[1];
                t2[1] <= t2[1] == `AGU ? `NULL : t2[1];
                t1[2] <= t1[2] == `AGU ? `NULL : t1[2];
                t2[2] <= t2[2] == `AGU ? `NULL : t2[2];
                t1[4] <= t1[4] == `AGU ? `NULL : t1[4];
                t2[4] <= t2[4] == `AGU ? `NULL : t2[4];
                t1[5] <= t1[5] == `AGU ? `NULL : t1[5];
                t2[5] <= t2[5] == `AGU ? `NULL : t2[5];
                t1[6] <= t1[6] == `AGU ? `NULL : t1[6];
                t2[6] <= t2[6] == `AGU ? `NULL : t2[6];
                t1[7] <= t1[7] == `AGU ? `NULL : t1[7];
                t2[7] <= t2[7] == `AGU ? `NULL : t2[7];
                {busy[3],op[3],r[3],r1[3],r2[3],t1[3],t2[3]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[3] <= 0;
            end
            else if (valid_inst[iptr[4]] & writeback[iptr[4]] & iptr[4]==raddr & retire_en[0] & busy[4]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `HILO ? `NULL : t1[0];
                t2[0] <= t2[0] == `HILO ? `NULL : t2[0];
                t1[1] <= t1[1] == `HILO ? `NULL : t1[1];
                t2[1] <= t2[1] == `HILO ? `NULL : t2[1];
                t1[2] <= t1[2] == `HILO ? `NULL : t1[2];
                t2[2] <= t2[2] == `HILO ? `NULL : t2[2];
                t1[3] <= t1[3] == `HILO ? `NULL : t1[3];
                t2[3] <= t2[3] == `HILO ? `NULL : t2[3];
                t1[5] <= t1[5] == `HILO ? `NULL : t1[5];
                t2[5] <= t2[5] == `HILO ? `NULL : t2[5];
                t1[6] <= t1[6] == `HILO ? `NULL : t1[6];
                t2[6] <= t2[6] == `HILO ? `NULL : t2[6];
                t1[7] <= t1[7] == `HILO ? `NULL : t1[7];
                t2[7] <= t2[7] == `HILO ? `NULL : t2[7];
                {busy[4],op[4],r[4],r1[4],r2[4],t1[4],t2[4]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[4] <= 0;
            end
            else if (valid_inst[iptr[5]] & writeback[iptr[5]] & iptr[5]==raddr & retire_en[0] & busy[5]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `ALU3 ? `NULL : t1[0];
                t2[0] <= t2[0] == `ALU3 ? `NULL : t2[0];
                t1[1] <= t1[1] == `ALU3 ? `NULL : t1[1];
                t2[1] <= t2[1] == `ALU3 ? `NULL : t2[1];
                t1[2] <= t1[2] == `ALU3 ? `NULL : t1[2];
                t2[2] <= t2[2] == `ALU3 ? `NULL : t2[2];
                t1[3] <= t1[3] == `ALU3 ? `NULL : t1[3];
                t2[3] <= t2[3] == `ALU3 ? `NULL : t2[3];
                t1[4] <= t1[4] == `ALU3 ? `NULL : t1[4];
                t2[4] <= t2[4] == `ALU3 ? `NULL : t2[4];
                t1[6] <= t1[6] == `ALU3 ? `NULL : t1[6];
                t2[6] <= t2[6] == `ALU3 ? `NULL : t2[6];
                t1[7] <= t1[7] == `ALU3 ? `NULL : t1[7];
                t2[7] <= t2[7] == `ALU3 ? `NULL : t2[7];
                {busy[5],op[5],r[5],r1[5],r2[5],t1[5],t2[5]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[5] <= 0;
            end
            else if (valid_inst[iptr[6]] & writeback[iptr[6]] & iptr[6]==raddr & retire_en[0] & busy[6]) begin
                // t1[1] <= t1[1] == `ALU1 ? `NULL : t1[1];
                t1[0] <= t1[0] == `ALU4 ? `NULL : t1[0];
                t2[0] <= t2[0] == `ALU4 ? `NULL : t2[0];
                t1[1] <= t1[1] == `ALU4 ? `NULL : t1[1];
                t2[1] <= t2[1] == `ALU4 ? `NULL : t2[1];
                t1[2] <= t1[2] == `ALU4 ? `NULL : t1[2];
                t2[2] <= t2[2] == `ALU4 ? `NULL : t2[2];
                t1[3] <= t1[3] == `ALU4 ? `NULL : t1[3];
                t2[3] <= t2[3] == `ALU4 ? `NULL : t2[3];
                t1[4] <= t1[4] == `ALU4 ? `NULL : t1[4];
                t2[4] <= t2[4] == `ALU4 ? `NULL : t2[4];
                t1[5] <= t1[5] == `ALU4 ? `NULL : t1[5];
                t2[5] <= t2[5] == `ALU4 ? `NULL : t2[5];
                t1[7] <= t1[7] == `ALU4 ? `NULL : t1[7];
                t2[7] <= t2[7] == `ALU4 ? `NULL : t2[7];
                {busy[6],op[6],r[6],r1[6],r2[6],t1[6],t2[6]} <= {1'b0,12'b0,6'b0,6'b111111,6'b111111,`NULL,`NULL};
                iptr[6] <= 0;
            end
            if (dispatch_ok) begin
                iptr[fu_ptr] <= inst_status[dptr][`ADDR];
                busy[fu_ptr] <= 1'b1;
                op[fu_ptr] <= inst_status[dptr][`OP];
                r[fu_ptr] <= inst_status[dptr][`REG3];
                r1[fu_ptr] <= inst_status[dptr][`R1VAL] ? inst_status[dptr][`REG1] : 6'b111111;
                r2[fu_ptr] <= inst_status[dptr][`R2VAL] ? inst_status[dptr][`REG2] : 6'b111111;
                t1[fu_ptr] <= inst_status[dptr][`R1VAL] ? (valid_inst[raddr] & writeback[raddr] & inst_status[dptr][`REG1]==inst_status[raddr][`REG3] ? `NULL : reg_status[inst_status[dptr][`REG1]]) : `NULL;
                t2[fu_ptr] <= inst_status[dptr][`R2VAL] ? (valid_inst[raddr] & writeback[raddr] & inst_status[dptr][`REG2]==inst_status[raddr][`REG3] ? `NULL : reg_status[inst_status[dptr][`REG2]]) : `NULL;
            end
        end
    end
    
    // assign fu_rdy[0] = (t1[0] == `NULL) & (t2[0] == `NULL);
    assign fu_rdy[0] = dispatch[iptr[0]] & ~issue[iptr[0]] & (t1[0] == `NULL) & (t2[0] == `NULL) & (inst_status[iptr[0]][`FU] == `ALU1);
    assign fu_rdy[1] = dispatch[iptr[1]] & ~issue[iptr[1]] & (t1[1] == `NULL) & (t2[1] == `NULL) & (inst_status[iptr[1]][`FU] == `ALU2);
    assign fu_rdy[2] = dispatch[iptr[2]] & ~issue[iptr[2]] & (t1[2] == `NULL) & (t2[2] == `NULL) & (inst_status[iptr[2]][`FU] == `BRU );
    assign fu_rdy[3] = dispatch[iptr[3]] & ~issue[iptr[3]] & (t1[3] == `NULL) & (t2[3] == `NULL) & (inst_status[iptr[3]][`FU] == `AGU );
    assign fu_rdy[4] = dispatch[iptr[4]] & ~issue[iptr[4]] & (t1[4] == `NULL) & (t2[4] == `NULL) & (inst_status[iptr[4]][`FU] == `HILO);
    assign fu_rdy[5] = dispatch[iptr[5]] & ~issue[iptr[5]] & (t1[5] == `NULL) & (t2[5] == `NULL) & (inst_status[iptr[5]][`FU] == `ALU3);
    assign fu_rdy[6] = dispatch[iptr[6]] & ~issue[iptr[6]] & (t1[6] == `NULL) & (t2[6] == `NULL) & (inst_status[iptr[6]][`FU] == `ALU4);
    assign fu_rdy[7] = dispatch[iptr[7]] & ~issue[iptr[7]] & (t1[7] == `NULL) & (t2[7] == `NULL) & (inst_status[iptr[7]][`FU] == 4'd7 );

    always @ (posedge clk) begin
        if (!resetn) begin
            reg_status[ 0] <= `NULL;
            reg_status[ 1] <= `NULL;
            reg_status[ 2] <= `NULL;
            reg_status[ 3] <= `NULL;
            reg_status[ 4] <= `NULL;
            reg_status[ 5] <= `NULL;
            reg_status[ 6] <= `NULL;
            reg_status[ 7] <= `NULL;
            reg_status[ 8] <= `NULL;
            reg_status[ 9] <= `NULL;
            reg_status[10] <= `NULL;
            reg_status[11] <= `NULL;
            reg_status[12] <= `NULL;
            reg_status[13] <= `NULL;
            reg_status[14] <= `NULL;
            reg_status[15] <= `NULL;
            reg_status[16] <= `NULL;
            reg_status[17] <= `NULL;
            reg_status[18] <= `NULL;
            reg_status[19] <= `NULL;
            reg_status[20] <= `NULL;
            reg_status[21] <= `NULL;
            reg_status[22] <= `NULL;
            reg_status[23] <= `NULL;
            reg_status[24] <= `NULL;
            reg_status[25] <= `NULL;
            reg_status[26] <= `NULL;
            reg_status[27] <= `NULL;
            reg_status[28] <= `NULL;
            reg_status[29] <= `NULL;
            reg_status[30] <= `NULL;
            reg_status[31] <= `NULL;
            reg_status[32] <= `NULL;
            reg_status[33] <= `NULL;
        end
        else if (br_bus[32]) begin
            reg_status[ 0] <= `NULL;
            reg_status[ 1] <= `NULL;
            reg_status[ 2] <= `NULL;
            reg_status[ 3] <= `NULL;
            reg_status[ 4] <= `NULL;
            reg_status[ 5] <= `NULL;
            reg_status[ 6] <= `NULL;
            reg_status[ 7] <= `NULL;
            reg_status[ 8] <= `NULL;
            reg_status[ 9] <= `NULL;
            reg_status[10] <= `NULL;
            reg_status[11] <= `NULL;
            reg_status[12] <= `NULL;
            reg_status[13] <= `NULL;
            reg_status[14] <= `NULL;
            reg_status[15] <= `NULL;
            reg_status[16] <= `NULL;
            reg_status[17] <= `NULL;
            reg_status[18] <= `NULL;
            reg_status[19] <= `NULL;
            reg_status[20] <= `NULL;
            reg_status[21] <= `NULL;
            reg_status[22] <= `NULL;
            reg_status[23] <= `NULL;
            reg_status[24] <= `NULL;
            reg_status[25] <= `NULL;
            reg_status[26] <= `NULL;
            reg_status[27] <= `NULL;
            reg_status[28] <= `NULL;
            reg_status[29] <= `NULL;
            reg_status[30] <= `NULL;
            reg_status[31] <= `NULL;
            reg_status[32] <= `NULL;
            reg_status[33] <= `NULL;
            if (dispatch_ok) begin
                reg_status[inst_status[dptr][`REG3]] <= inst_status[dptr][`REG3]==0 ? `NULL : inst_status[dptr][`FU];
            end
        end
        else begin
            // if (valid_inst[iptr[0]] & writeback[iptr[0]]) begin
            //     reg_status[inst_status[iptr[0]][`REG3]] <= `NULL;
            // end
            // if (valid_inst[iptr[2]] & writeback[iptr[2]]) begin
            //     reg_status[inst_status[iptr[2]][`REG3]] <= `NULL;
            // end
            // if (valid_inst[iptr[3]] & writeback[iptr[3]]) begin
            //     reg_status[inst_status[iptr[3]][`REG3]] <= `NULL;
            // end
            if (valid_inst[raddr] & writeback[raddr]) begin
                reg_status[inst_status[raddr][`REG3]] <= `NULL;
            end
            if (dispatch_ok) begin
                reg_status[inst_status[dptr][`REG3]] <= inst_status[dptr][`REG3]==0 ? `NULL : inst_status[dptr][`FU];
            end
        end
    end

    wire [5:0] raddr1 [7:0];
    wire [5:0] raddr2 [7:0];
    wire [31:0] rdata1 [7:0];
    wire [31:0] rdata2 [7:0];
    wire [31:0] rdata_hi;
    wire [3:0] rf_we_o;
    wire [5:0] rf_waddr [3:0];
    wire [63:0] rf_wdata [3:0];
    // assign raddr1[0] = r1[0];
    // assign raddr2[0] = r2[0];
    assign raddr1[0] = r1[0];
    assign raddr2[0] = r2[0];
    assign raddr1[1] = r1[1];
    assign raddr2[1] = r2[1];
    assign raddr1[2] = r1[2];
    assign raddr2[2] = r2[2];
    assign raddr1[3] = r1[3];
    assign raddr2[3] = r2[3];
    assign raddr1[4] = r1[4];
    assign raddr2[4] = r2[4];
    assign raddr1[5] = r1[5];
    assign raddr2[5] = r2[5];
    assign raddr1[6] = r1[6];
    assign raddr2[6] = r2[6];
    assign raddr1[7] = r1[7];
    assign raddr2[7] = r2[7];

    assign rf_we_o[0] = retire_en[0] ? rf_we_r[raddr] : 1'b0;
    assign rf_waddr[0] = retire_en[0] ? inst_status[raddr][`REG3] : 6'b0;
    assign rf_wdata[0] = retire_en[0] ? {cb_extra[raddr], cb[raddr]} : 64'b0;

    assign debug_wb_pc = retire_en[0] ? inst_status[raddr][`PC] : 32'b0;
    assign debug_wb_rf_wen = {4{rf_we_o[0]}};
    assign debug_wb_rf_wnum = rf_waddr[0];
    assign debug_wb_rf_wdata = rf_wdata[0][31:0];

    regfile u_regfile(
    	.clk     (clk     ),
        .raddr01 (raddr1[0] ),
        .raddr02 (raddr2[0] ),
        .rdata01 (rdata1[0] ),
        .rdata02 (rdata2[0] ),
        .raddr11 (raddr1[1] ),
        .raddr12 (raddr2[1] ),
        .rdata11 (rdata1[1] ),
        .rdata12 (rdata2[1] ),
        .raddr21 (raddr1[2] ),
        .raddr22 (raddr2[2] ),
        .rdata21 (rdata1[2] ),
        .rdata22 (rdata2[2] ),
        .raddr31 (raddr1[3] ),
        .raddr32 (raddr2[3] ),
        .rdata31 (rdata1[3] ),
        .rdata32 (rdata2[3] ),
        .raddr41 (raddr1[4] ),
        .raddr42 (raddr2[4] ),
        .rdata41 (rdata1[4] ),
        .rdata42 ({rdata_hi, rdata2[4]} ),
        .raddr51 (raddr1[5] ),
        .raddr52 (raddr2[5] ),
        .rdata51 (rdata1[5] ),
        .rdata52 (rdata2[5] ),
        .raddr61 (raddr1[6] ),
        .raddr62 (raddr2[6] ),
        .rdata61 (rdata1[6] ),
        .rdata62 (rdata2[6] ),
        .raddr71 (raddr1[7] ),
        .raddr72 (raddr2[7] ),
        .rdata71 (rdata1[7] ),
        .rdata72 (rdata2[7] ),
        .we0     (rf_we_o[0] ),
        .we1     (rf_we_o[1] ),
        .we2     (rf_we_o[2] ),
        .we3     (rf_we_o[3] ),
        .waddr0  (rf_waddr[0]),
        .waddr1  (rf_waddr[1]),
        .waddr2  (rf_waddr[2]),
        .waddr3  (rf_waddr[3]),
        .wdata0  (rf_wdata[0]),
        .wdata1  (rf_wdata[1]),
        .wdata2  (rf_wdata[2]),
        .wdata3  (rf_wdata[3])
    );

    FU_ALU u0_FU(
    	.clk         (clk                   ),
        .resetn      (resetn                ),
        .ready       (fu_rdy[0]             ),
        .op          (op[0]                 ),
        .inst_status (inst_status[iptr[0]]  ),
        .rdata1      (rdata1[0]             ),
        .rdata2      (rdata2[0]             ),
        .cb_we       (cb_we[0]              ),
        .rf_we       (rf_we[0]              ),
        .wdata       (wdata[0]              )
    );

    FU_ALU u1_FU(
    	.clk         (clk                   ),
        .resetn      (resetn                ),
        .ready       (fu_rdy[1]             ),
        .op          (op[1]                 ),
        .inst_status (inst_status[iptr[1]]  ),
        .rdata1      (rdata1[1]             ),
        .rdata2      (rdata2[1]             ),
        .cb_we       (cb_we[1]              ),
        .rf_we       (rf_we[1]              ),
        .wdata       (wdata[1]              )
    );
    

    FU_BRU u2_FU(
    	.clk         (clk                   ),
        .resetn      (resetn                ),
        .ready       (fu_rdy[2]             ),
        .op          (op[2]                 ),
        .inst_status (inst_status[iptr[2]]  ),
        .rdata1      (rdata1[2]             ),
        .rdata2      (rdata2[2]             ),
        .cb_we       (cb_we[2]              ),
        .rf_we       (rf_we[2]              ),
        .wdata       (wdata[2]              ),
        .extra_wdata (extra_wdata[2]        ),
        .br_e        (br_e                  )
    );

    FU_AGU u3_FU(
    	.clk             (clk               ),
        .resetn          (resetn            ),
        .ready           (fu_rdy[3]         ),
        .dcache_miss     (dcache_miss       ),
        .op              (op[3]             ),
        .inst_status     (inst_status[iptr[3]]),
        .rdata1          (rdata1[3]         ),
        .rdata2          (rdata2[3]         ),
        .cb_we           (cb_we[3]          ),
        .rf_we           (rf_we[3]          ),
        .wdata           (wdata[3]          ),
        .data_sram_en    (data_sram_en      ),
        .data_sram_wen   (data_sram_wen     ),
        .data_sram_addr  (data_sram_addr    ),
        .data_sram_wdata (data_sram_wdata   ),
        .data_sram_rdata (data_sram_rdata   )
    );
    
    FU_HILO u4_FU(
    	.clk         (clk         ),
        .resetn      (resetn      ),
        .ready       (fu_rdy[4]       ),
        .op          (op[4]          ),
        .inst_status (inst_status[iptr[4]] ),
        .rdata1      (rdata1[4]      ),
        .rdata2      ({rdata_hi, rdata2[4]}),
        .cb_we       (cb_we[4]       ),
        .rf_we       (rf_we[4]       ),
        .wdata       (wdata[4]       ),
        .extra_wdata (extra_wdata[4] )
    );

    FU_ALU u5_FU(
    	.clk         (clk         ),
        .resetn      (resetn      ),
        .ready       (fu_rdy[5]       ),
        .op          (op[5]          ),
        .inst_status (inst_status[iptr[5]] ),
        .rdata1      (rdata1[5]      ),
        .rdata2      (rdata2[5]      ),
        .cb_we       (cb_we[5]       ),
        .rf_we       (rf_we[5]       ),
        .wdata       (wdata[5]       )
    );
    
    FU_ALU u6_FU(
    	.clk         (clk         ),
        .resetn      (resetn      ),
        .ready       (fu_rdy[6]       ),
        .op          (op[6]          ),
        .inst_status (inst_status[iptr[6]] ),
        .rdata1      (rdata1[6]      ),
        .rdata2      (rdata2[6]      ),
        .cb_we       (cb_we[6]       ),
        .rf_we       (rf_we[6]       ),
        .wdata       (wdata[6]       )
    );
    
    
    


    always @ (posedge clk) begin
        if (!resetn) begin
            cb[ 0] <= 32'b0; cb_extra[ 0] <= 32'b0;
            cb[ 1] <= 32'b0; cb_extra[ 1] <= 32'b0;
            cb[ 2] <= 32'b0; cb_extra[ 2] <= 32'b0;
            cb[ 3] <= 32'b0; cb_extra[ 3] <= 32'b0;
            cb[ 4] <= 32'b0; cb_extra[ 4] <= 32'b0;
            cb[ 5] <= 32'b0; cb_extra[ 5] <= 32'b0;
            cb[ 6] <= 32'b0; cb_extra[ 6] <= 32'b0;
            cb[ 7] <= 32'b0; cb_extra[ 7] <= 32'b0;
            cb[ 8] <= 32'b0; cb_extra[ 8] <= 32'b0;
            cb[ 9] <= 32'b0; cb_extra[ 9] <= 32'b0;
            cb[10] <= 32'b0; cb_extra[10] <= 32'b0;
            cb[11] <= 32'b0; cb_extra[11] <= 32'b0;
            cb[12] <= 32'b0; cb_extra[12] <= 32'b0;
            cb[13] <= 32'b0; cb_extra[13] <= 32'b0;
            cb[14] <= 32'b0; cb_extra[14] <= 32'b0;
            cb[15] <= 32'b0; cb_extra[15] <= 32'b0;
            cb[16] <= 32'b0; cb_extra[16] <= 32'b0;
            cb[17] <= 32'b0; cb_extra[17] <= 32'b0;
            cb[18] <= 32'b0; cb_extra[18] <= 32'b0;
            cb[19] <= 32'b0; cb_extra[19] <= 32'b0;
            cb[20] <= 32'b0; cb_extra[20] <= 32'b0;
            cb[21] <= 32'b0; cb_extra[21] <= 32'b0;
            cb[22] <= 32'b0; cb_extra[22] <= 32'b0;
            cb[23] <= 32'b0; cb_extra[23] <= 32'b0;
            cb[24] <= 32'b0; cb_extra[24] <= 32'b0;
            cb[25] <= 32'b0; cb_extra[25] <= 32'b0;
            cb[26] <= 32'b0; cb_extra[26] <= 32'b0;
            cb[27] <= 32'b0; cb_extra[27] <= 32'b0;
            cb[28] <= 32'b0; cb_extra[28] <= 32'b0;
            cb[29] <= 32'b0; cb_extra[29] <= 32'b0;
            cb[30] <= 32'b0; cb_extra[30] <= 32'b0;
            cb[31] <= 32'b0; cb_extra[31] <= 32'b0;
            rf_we_r <= 16'b0;
            br_e_r <= 16'b0;
        end
        else begin
            if (cb_we[0]) {rf_we_r[iptr[0]], cb[iptr[0]]} <= {rf_we[0], wdata[0]};
            if (cb_we[1]) {rf_we_r[iptr[1]], cb[iptr[1]]} <= {rf_we[1], wdata[1]};
            if (cb_we[2]) {br_e_r[iptr[2]], rf_we_r[iptr[2]], cb[iptr[2]], cb_extra[iptr[2]]} <= {br_e, rf_we[2], wdata[2], extra_wdata[2]};
            if (cb_we[3]) {rf_we_r[iptr[3]], cb[iptr[3]]} <= {rf_we[3], wdata[3]};
            if (cb_we[4]) {rf_we_r[iptr[4]], cb[iptr[4]], cb_extra[iptr[4]]} <= {rf_we[4], wdata[4], extra_wdata[4]};
            if (cb_we[5]) {rf_we_r[iptr[5]], cb[iptr[5]]} <= {rf_we[5], wdata[5]};
            if (cb_we[6]) {rf_we_r[iptr[6]], cb[iptr[6]]} <= {rf_we[6], wdata[6]};
            if (br_bus[32]) br_e_r <= 16'b0;
        end
    end

    assign br_bus = {br_e_r[raddr]&retire_en[0], {32{retire_en[0]}}&cb_extra[raddr]};
    
    assign wb_ok[0] = ~(r[0]==r1[1] & t1[1]!=`ALU1 |
                        r[0]==r2[1] & t2[1]!=`ALU1 |
                        r[0]==r1[2] & t1[2]!=`ALU1 |
                        r[0]==r2[2] & t2[2]!=`ALU1 |
                        r[0]==r1[3] & t1[3]!=`ALU1 |
                        r[0]==r2[3] & t2[3]!=`ALU1 |
                        r[0]==r1[4] & t1[4]!=`ALU1 |
                        r[0]==r2[4] & t2[4]!=`ALU1 |
                        r[0]==r1[5] & t1[5]!=`ALU1 |
                        r[0]==r2[5] & t2[5]!=`ALU1 |
                        r[0]==r1[6] & t1[6]!=`ALU1 |
                        r[0]==r2[6] & t2[6]!=`ALU1 |
                        r[0]==r1[7] & t1[7]!=`ALU1 |
                        r[0]==r2[7] & t2[7]!=`ALU1 ) | r[0] == 0;
    assign wb_ok[1] = ~(r[1]==r1[0] & t1[0]!=`ALU2 |
                        r[1]==r2[0] & t2[0]!=`ALU2 |
                        r[1]==r1[2] & t1[2]!=`ALU2 |
                        r[1]==r2[2] & t2[2]!=`ALU2 |
                        r[1]==r1[3] & t1[3]!=`ALU2 |
                        r[1]==r2[3] & t2[3]!=`ALU2 |
                        r[1]==r1[4] & t1[4]!=`ALU2 |
                        r[1]==r2[4] & t2[4]!=`ALU2 |
                        r[1]==r1[5] & t1[5]!=`ALU2 |
                        r[1]==r2[5] & t2[5]!=`ALU2 |
                        r[1]==r1[6] & t1[6]!=`ALU2 |
                        r[1]==r2[6] & t2[6]!=`ALU2 |
                        r[1]==r1[7] & t1[7]!=`ALU2 |
                        r[1]==r2[7] & t2[7]!=`ALU2 ) | r[1] == 0;
    assign wb_ok[2] = ~(r[2]==r1[0] & t1[0]!=`BRU |
                        r[2]==r2[0] & t2[0]!=`BRU |
                        r[2]==r1[1] & t1[1]!=`BRU |
                        r[2]==r2[1] & t2[1]!=`BRU |
                        r[2]==r1[3] & t1[3]!=`BRU |
                        r[2]==r2[3] & t2[3]!=`BRU |
                        r[2]==r1[4] & t1[4]!=`BRU |
                        r[2]==r2[4] & t2[4]!=`BRU |
                        r[2]==r1[5] & t1[5]!=`BRU |
                        r[2]==r2[5] & t2[5]!=`BRU |
                        r[2]==r1[6] & t1[6]!=`BRU |
                        r[2]==r2[6] & t2[6]!=`BRU |
                        r[2]==r1[7] & t1[7]!=`BRU |
                        r[2]==r2[7] & t2[7]!=`BRU ) | r[2] == 0;
    assign wb_ok[3] = ~(r[3]==r1[0] & t1[0]!=`AGU |
                        r[3]==r2[0] & t2[0]!=`AGU |
                        r[3]==r1[1] & t1[1]!=`AGU |
                        r[3]==r2[1] & t2[1]!=`AGU |
                        r[3]==r1[2] & t1[2]!=`AGU |
                        r[3]==r2[2] & t2[2]!=`AGU |
                        r[3]==r1[4] & t1[4]!=`AGU |
                        r[3]==r2[4] & t2[4]!=`AGU |
                        r[3]==r1[5] & t1[5]!=`AGU |
                        r[3]==r2[5] & t2[5]!=`AGU |
                        r[3]==r1[6] & t1[6]!=`AGU |
                        r[3]==r2[6] & t2[6]!=`AGU |
                        r[3]==r1[7] & t1[7]!=`AGU |
                        r[3]==r2[7] & t2[7]!=`AGU ) | r[3] == 0;
    assign wb_ok[4] = ~(r[4]==r1[0] & t1[0]!=`HILO |
                        r[4]==r2[0] & t2[0]!=`HILO |
                        r[4]==r1[1] & t1[1]!=`HILO |
                        r[4]==r2[1] & t2[1]!=`HILO |
                        r[4]==r1[2] & t1[2]!=`HILO |
                        r[4]==r2[2] & t2[2]!=`HILO |
                        r[4]==r1[3] & t1[3]!=`HILO |
                        r[4]==r2[3] & t2[3]!=`HILO |
                        r[4]==r1[5] & t1[5]!=`HILO |
                        r[4]==r2[5] & t2[5]!=`HILO |
                        r[4]==r1[6] & t1[6]!=`HILO |
                        r[4]==r2[6] & t2[6]!=`HILO |
                        r[4]==r1[7] & t1[7]!=`HILO |
                        r[4]==r2[7] & t2[7]!=`HILO ) | r[4] == 0;
    assign wb_ok[5] = ~(r[5]==r1[0] & t1[0]!=`ALU3 |
                        r[5]==r2[0] & t2[0]!=`ALU3 |
                        r[5]==r1[1] & t1[1]!=`ALU3 |
                        r[5]==r2[1] & t2[1]!=`ALU3 |
                        r[5]==r1[2] & t1[2]!=`ALU3 |
                        r[5]==r2[2] & t2[2]!=`ALU3 |
                        r[5]==r1[3] & t1[3]!=`ALU3 |
                        r[5]==r2[3] & t2[3]!=`ALU3 |
                        r[5]==r1[4] & t1[4]!=`ALU3 |
                        r[5]==r2[4] & t2[4]!=`ALU3 |
                        r[5]==r1[6] & t1[6]!=`ALU3 |
                        r[5]==r2[6] & t2[6]!=`ALU3 |
                        r[5]==r1[7] & t1[7]!=`ALU3 |
                        r[5]==r2[7] & t2[7]!=`ALU3 ) | r[5] == 0;
    assign wb_ok[6] = ~(r[6]==r1[0] & t1[0]!=`ALU4 |
                        r[6]==r2[0] & t2[0]!=`ALU4 |
                        r[6]==r1[1] & t1[1]!=`ALU4 |
                        r[6]==r2[1] & t2[1]!=`ALU4 |
                        r[6]==r1[2] & t1[2]!=`ALU4 |
                        r[6]==r2[2] & t2[2]!=`ALU4 |
                        r[6]==r1[3] & t1[3]!=`ALU4 |
                        r[6]==r2[3] & t2[3]!=`ALU4 |
                        r[6]==r1[4] & t1[4]!=`ALU4 |
                        r[6]==r2[4] & t2[4]!=`ALU4 |
                        r[6]==r1[5] & t1[5]!=`ALU4 |
                        r[6]==r2[5] & t2[5]!=`ALU4 |
                        r[6]==r1[7] & t1[7]!=`ALU4 |
                        r[6]==r2[7] & t2[7]!=`ALU4 ) | r[6] == 0;
    assign wb_ok[7] = 0;
endmodule