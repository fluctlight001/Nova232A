`include "lib/defines.vh"
module mycpu_top(
    input wire aclk,
    input wire aresetn,
    input wire [5:0] ext_int,

    output wire[3:0]   arid,
    output wire[31:0]  araddr,
    output wire[3:0]   arlen,
    output wire[2:0]   arsize,
    output wire[1:0]   arburst,
    output wire[1:0]   arlock,
    output wire[3:0]   arcache,
    output wire[2:0]   arprot,
    output wire        arvalid,
    input  wire        arready,

    input  wire[3:0]   rid,
    input  wire[31:0]  rdata,
    input  wire[1:0]   rresp,
    input  wire        rlast,
    input  wire        rvalid,
    output wire        rready,

    output wire[3:0]   awid,
    output wire[31:0]  awaddr,
    output wire[3:0]   awlen,
    output wire[2:0]   awsize,
    output wire[1:0]   awburst,
    output wire[1:0]   awlock,
    output wire[3:0]   awcache,
    output wire[2:0]   awprot,
    output wire        awvalid,
    input  wire        awready,

    output wire[3:0]   wid,
    output wire[31:0]  wdata,
    output wire[3:0]   wstrb,
    output wire        wlast,
    output wire        wvalid,
    input  wire        wready,

    input  wire[3:0]   bid,
    input  wire[1:0]   bresp,
    input  wire        bvalid,
    output wire        bready,

    output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata 
);

    //cpu inst sram
    wire        cpu_inst_en;
    wire [3 :0] cpu_inst_wen;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_wdata;
    wire [63:0] cpu_inst_rdata;
    //cpu data sram
    wire        cpu_data_en;
    wire [3 :0] cpu_data_wen;
    wire [31:0] cpu_data_addr;
    wire [31:0] cpu_data_wdata;
    wire [31:0] cpu_data_rdata;

    //data sram
    wire        data_sram_en;
    wire [3 :0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;
    //conf
    wire        conf_en;
    wire [3 :0] conf_wen;
    wire [31:0] conf_addr;
    wire [31:0] conf_wdata;
    wire [31:0] conf_rdata;

    mycpu_core u_mycpu_core(
    	.clk              (aclk          ),
        .resetn           (aresetn       ),
        .int              (ext_int       ),

        .inst_sram_en     (cpu_inst_en   ),
        .inst_sram_wen    (cpu_inst_wen  ),
        .inst_sram_addr   (cpu_inst_addr ),
        .inst_sram_wdata  (cpu_inst_wdata),
        .inst_sram_rdata  (cpu_inst_rdata),
        
        .data_sram_en     (cpu_data_en   ),
        .data_sram_wen    (cpu_data_wen  ),
        .data_sram_addr   (cpu_data_addr ),
        .data_sram_wdata  (cpu_data_wdata),
        .data_sram_rdata  (cpu_data_rdata),

        //debug
        .debug_wb_pc      (debug_wb_pc      ),
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );


    bridge_1x2 u_bridge_1x2(
    	.clk             (aclk            ),
        .resetn          (aresetn         ),

        .cpu_data_en     (cpu_data_en     ),
        .cpu_data_wen    (cpu_data_wen    ),
        .cpu_data_addr   (cpu_data_addr   ),
        .cpu_data_wdata  (cpu_data_wdata  ),
        .cpu_data_rdata  (cpu_data_rdata  ),

        .data_sram_en    (data_sram_en    ),
        .data_sram_wen   (data_sram_wen   ),
        .data_sram_addr  (data_sram_addr  ),
        .data_sram_wdata (data_sram_wdata ),
        .data_sram_rdata (data_sram_rdata ),
        
        .conf_en         (conf_en         ),
        .conf_wen        (conf_wen        ),
        .conf_addr       (conf_addr       ),
        .conf_wdata      (conf_wdata      ),
        .conf_rdata      (conf_rdata      )
    );
    
    
    
endmodule 