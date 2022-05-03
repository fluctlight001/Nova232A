`include "../defines.vh"
module line(
    input wire clk,
    input wire en,
    input wire [3:0] wen,
    input wire [31:0] addr,
    input wire [31:0] din,
    output wire [31:0] dout,

    input wire reload,
    input wire [255:0] cacheline_new,
    output wire [255:0] cacheline_old
);
    wire [7:0] bank_sel;
    wire [7:0] bank_en;
    wire [3:0] bank_wen [7:0];
    wire [31:0] bank_din [7:0];
    wire [31:0] bank_dout [7:0];

    genvar i;
    generate 
        for (i = 0; i < 8; i = i + 1) begin : bank
            bank u_bank(
                .clk   (clk   ),
                .en    (bank_en[i]    ),
                .wen   (bank_wen[i]   ),
                .index (index ),
                .din   (bank_din[i]   ),
                .dout  (bank_dout[i]  )
            );        
        end
    endgenerate
    

    wire [19:0] tag;
    wire [6:0] index;
    wire [2:0] offset;
    
    decoder_3_8 u_decoder_3_8(
    	.in  (offset  ),
        .out (bank_sel )
    );

    assign bank_en = reload ? 8'hff : bank_sel;
    // assign bank_wen = {we}
    
endmodule