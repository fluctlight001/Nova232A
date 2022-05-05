`include "lib/defines.vh"

module uncache(
    input wire clk,
    input wire resetn,
    output wire stallreq,

    input wire conf_en,
    input wire [3:0] conf_wen,
    input wire [31:0] conf_addr,
    input wire [31:0] conf_wdata,
    output reg [31:0] conf_rdata,

    output wire rd_req,
    output wire [31:0] rd_addr,
    output wire wr_req,
    output wire [3:0] wr_wstrb,
    output wire [31:0] wr_addr,
    output wire [31:0] wr_data,

    input wire reload,
    input wire [31:0] rd_data
);
    reg valid;

    assign stallreq = conf_en & ~valid;
    always @ (posedge clk) begin
        if (!resetn) begin
            valid <= 1'b0;
        end
        else if (reload) begin
            valid <= 1'b1;
        end
        else if (!conf_en) begin
            valid <= 1'b0;
        end
    end

    assign rd_req = conf_en & ~valid & ~(|conf_wen);
    assign rd_addr = conf_addr;
    assign wr_req = conf_en & ~valid & (|conf_wen);
    assign wr_wstrb = conf_wen;
    assign wr_addr = conf_addr;
    assign wr_data = conf_wdata;

    always @ (posedge clk) begin
        if (!resetn) begin
            conf_rdata <= 32'b0;
        end
        else if (reload) begin
            conf_rdata <= rd_data; 
        end
    end
endmodule