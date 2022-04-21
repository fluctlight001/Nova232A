`include "lib/defines.vh"
module regfile(
    input wire clk,

    input wire [5:0] raddr01, raddr02,
    output wire [31:0] rdata01, rdata02,
    
    input wire [5:0] raddr11, raddr12,
    output wire [31:0] rdata11, rdata12,

    input wire [5:0] raddr21, raddr22,
    output wire [31:0] rdata21, rdata22,

    input wire [5:0] raddr31, raddr32,
    output wire [31:0] rdata31, rdata32,

    input wire [5:0] raddr41, raddr42,
    output wire [31:0] rdata41, 
    output wire [63:0] rdata42,
    
    input wire [5:0] raddr51, raddr52,
    output wire [31:0] rdata51, rdata52,

    input wire [5:0] raddr61, raddr62,
    output wire [31:0] rdata61, rdata62,

    input wire [5:0] raddr71, raddr72,
    output wire [31:0] rdata71, rdata72,

    input wire we0, we1, we2, we3, 
    input wire [5:0] waddr0, waddr1, waddr2, waddr3,
    input wire [63:0] wdata0, wdata1, wdata2, wdata3
);
    reg [31:0] reg_array [31:0]; // gpr
    reg [63:0] hilo_reg;
    // // write
    // always @ (posedge clk) begin
    //     if (we && waddr!=6'b0) begin
    //         reg_array[waddr] <= wdata;
    //     end
    // end

    // // read out 1
    // assign rdata1 = (raddr1 == 6'b0) ? 32'b0 : reg_array[raddr1];

    // // read out2
    // assign rdata2 = (raddr2 == 6'b0) ? 32'b0 : reg_array[raddr2];

    // write
    always @ (posedge clk) begin
        if (we0 && waddr0!=6'b0 && waddr0!=6'd32) reg_array[waddr0] <= wdata0[31:0];
        else if (we0 && waddr0 == 6'd32) hilo_reg <= wdata0;
        if (we1 && waddr1!=6'b0) reg_array[waddr1] <= wdata1;
        if (we2 && waddr2!=6'b0) reg_array[waddr2] <= wdata2;
        if (we3 && waddr3!=6'b0) reg_array[waddr3] <= wdata3;
    end

    // read 
    assign rdata01 = (raddr01 == 6'b0) ? 32'b0 : waddr0 == raddr01 ? wdata0[31:0] : reg_array[raddr01];
    assign rdata02 = (raddr02 == 6'b0) ? 32'b0 : waddr0 == raddr02 ? wdata0[31:0] : reg_array[raddr02];
    assign rdata11 = (raddr11 == 6'b0) ? 32'b0 : waddr0 == raddr11 ? wdata0[31:0] : reg_array[raddr11];
    assign rdata12 = (raddr12 == 6'b0) ? 32'b0 : waddr0 == raddr12 ? wdata0[31:0] : reg_array[raddr12];
    assign rdata21 = (raddr21 == 6'b0) ? 32'b0 : waddr0 == raddr21 ? wdata0[31:0] : reg_array[raddr21];
    assign rdata22 = (raddr22 == 6'b0) ? 32'b0 : waddr0 == raddr22 ? wdata0[31:0] : reg_array[raddr22];
    assign rdata31 = (raddr31 == 6'b0) ? 32'b0 : waddr0 == raddr31 ? wdata0[31:0] : reg_array[raddr31];
    assign rdata32 = (raddr32 == 6'b0) ? 32'b0 : waddr0 == raddr32 ? wdata0[31:0] : reg_array[raddr32];
    assign rdata41 = (raddr41 == 6'b0) ? 32'b0 : waddr0 == raddr41 ? wdata0[31:0] : reg_array[raddr41];
    assign rdata42 = (raddr42 == 6'b0) ? 64'b0 : waddr0 == raddr42 ? wdata0 : (raddr42 == 6'd32) ? hilo_reg : {32'b0, reg_array[raddr42]};
    assign rdata51 = (raddr51 == 6'b0) ? 32'b0 : waddr0 == raddr51 ? wdata0[31:0] : reg_array[raddr51];
    assign rdata52 = (raddr52 == 6'b0) ? 32'b0 : waddr0 == raddr52 ? wdata0[31:0] : reg_array[raddr52];
    assign rdata61 = (raddr61 == 6'b0) ? 32'b0 : waddr0 == raddr61 ? wdata0[31:0] : reg_array[raddr61];
    assign rdata62 = (raddr62 == 6'b0) ? 32'b0 : waddr0 == raddr62 ? wdata0[31:0] : reg_array[raddr62];
    assign rdata71 = (raddr71 == 6'b0) ? 32'b0 : reg_array[raddr71];
    assign rdata72 = (raddr72 == 6'b0) ? 32'b0 : reg_array[raddr72];

endmodule