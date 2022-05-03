`include "lib/defines.vh"
`define TAG_WD 21
`define INDEX_WD 7
`define LRU_WD 128
`define OFFSET_WD 5
module dcache(
    input wire clk,
    input wire resetn,
    output wire stallreq,

    input wire data_sram_en,
    input wire [3:0] data_sram_wen,
    input wire [31:0] data_sram_addr,
    input wire [31:0] data_sram_wdata,
    output wire [31:0] data_sram_rdata,

    output wire rd_req,
    output wire [31:0] rd_addr,
    output wire wr_req,
    output wire [31:0] wr_addr,

    input wire reload
);
    reg [`LRU_WD-1:0] lru;
    wire [`TAG_WD-2:0] tag;
    wire [`INDEX_WD-1:0] index;
    wire [`OFFSET_WD-1:0] offset;
    wire hit;
    wire miss;

    wire hit_way0, hit_way1;
    wire [`TAG_WD-1:0] tag_way0, tag_way1;
    always @ (posedge clk) begin
        if (!resetn) begin
            lru <= `LRU_WD'b0;
        end
        else if (hit_way0) begin
            lru[index] <= 1'b1;
        end
        else if (hit_way1) begin
            lru[index] <= 1'b0;
        end
        
    end

    dcache_tag u0_tag(
        .clk    (clk        ),
        .we     (reload     ),
        .a      (index      ),
        .d      ({1'b1, tag}),
        .spo    (tag_way0   )
    );
    dcache_tag u1_tag(
        .clk    (clk        ),
        .we     (reload     ),
        .a      (index      ),
        .d      ({1'b1, tag}),
        .spo    (tag_way1   )
    );

    assign {tag, index, offset} = data_sram_addr;
    assign hit_way0 = data_sram_en & {1'b1, tag} == tag_way0;
    assign hit_way1 = data_sram_en & {1'b1, tag} == tag_way1;
    assign hit = hit_way0 | hit_way1;
    assign miss = data_sram_en & ~hit;
    assign stallreq = miss;
    assign rd_req = data_sram_en & miss;
    assign rd_addr = {data_sram_addr[31:5],5'b0};
    assign wr_req = data_sram_en & miss & (lru[index] ? tag_way1[`TAG_WD-1] : tag_way0[`TAG_WD-1]);
    assign wr_addr = lru[index] ? {tag_way1[`TAG_WD-2:0], index, 5'b0} : {tag_way0[`TAG_WD-2:0], index, 5'b0};


endmodule