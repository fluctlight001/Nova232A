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
    wire inst_sram_en;
    wire [3:0] inst_sram_wen;
    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_wdata;
    wire [31:0] inst_sram_rdata;

    wire data_sram_en;
    wire [3:0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;

    wire [31:0] inst_sram_addr_v, data_sram_addr_v;

    // icache tag
    wire icache_cached;
    wire icache_refresh;
    wire icache_miss;
    wire [31:0] icache_raddr;
    wire icache_write_back;
    wire [31:0] icache_waddr;
    wire [`HIT_WIDTH-1:0] icache_hit;
    wire [`LRU_WIDTH-1:0] icache_lru;

    // icache data
    wire [`CACHELINE_WIDTH-1:0] icache_cacheline_new;
    wire [`CACHELINE_WIDTH-1:0] icache_cacheline_old;

    // dcache tag
    wire dcache_cached;
    wire dcache_refresh;
    wire dcache_miss;
    wire [31:0] dcache_raddr;
    wire dcache_write_back;
    wire [31:0] dcache_waddr;
    wire [`HIT_WIDTH-1:0] dcache_hit;
    wire [`LRU_WIDTH-1:0] dcache_lru;

    // dcache data
    wire [`CACHELINE_WIDTH-1:0] dcache_cacheline_new;
    wire [`CACHELINE_WIDTH-1:0] dcache_cacheline_old;

    // uncache tag
    wire uncache_refresh;
    wire uncache_en;
    wire [3:0] uncache_wen;
    wire [31:0] uncache_addr;
    wire uncache_hit;
    
    // uncache data
    wire [31:0] uncache_rdata;

    //ctrl 
    // wire stallreq_from_out;
    wire stallreq_from_axi;
    wire stallreq_from_icache;
    wire stallreq_from_dcache;
    wire stallreq_from_uncache;
    // assign stallreq_from_out = stallreq_from_icache | stallreq_from_dcache | stallreq_from_uncache;
    mycpu_core u_mycpu_core(
    	.clk               (aclk              ),
        .resetn            (aresetn           ),
        .int               (ext_int           ),
        .stallreq_from_i   (stallreq_from_icache | stallreq_from_dcache | stallreq_from_uncache | stallreq_from_axi),
        .stallreq_from_d   (stallreq_from_dcache | stallreq_from_uncache | stallreq_from_axi),
        .inst_sram_en      (inst_sram_en      ),
        .inst_sram_wen     (inst_sram_wen     ),
        .inst_sram_addr    (inst_sram_addr_v  ),
        .inst_sram_wdata   (inst_sram_wdata   ),
        .inst_sram_rdata   (inst_sram_rdata   ),
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

    assign flush = 1'b0;

    axi_control_v5 u_axi_control(
    	.clk                  (aclk                  ),
        .rstn                 (aresetn              ),

        .icache_ren           (icache_miss           ),
        .icache_raddr         (icache_raddr         ),
        .icache_cacheline_new (icache_cacheline_new ),
        .icache_wen           (1'b0           ),
        .icache_waddr         (icache_waddr         ),
        .icache_cacheline_old (icache_cacheline_old ),
        .icache_refresh       (icache_refresh       ),

        .dcache_ren           (dcache_miss           ),
        .dcache_raddr         (dcache_raddr         ),
        .dcache_cacheline_new (dcache_cacheline_new ),
        .dcache_wen           (dcache_write_back           ),
        .dcache_waddr         (dcache_waddr         ),
        .dcache_cacheline_old (dcache_cacheline_old ),
        .dcache_refresh       (dcache_refresh       ),

        .uncache_en           (uncache_en           ),
        .uncache_wen          (uncache_wen          ),
        .uncache_addr         (uncache_addr         ),
        .uncache_wdata        (data_sram_wdata      ),
        .uncache_rdata        (uncache_rdata        ),
        .uncache_refresh      (uncache_refresh      ),

        .stallreq             (stallreq_from_axi    ),

        .arid                 (arid                 ),
        .araddr               (araddr               ),
        .arlen                (arlen                ),
        .arsize               (arsize               ),
        .arburst              (arburst              ),
        .arlock               (arlock               ),
        .arcache              (arcache              ),
        .arprot               (arprot               ),
        .arvalid              (arvalid              ),
        .arready              (arready              ),
        .rid                  (rid                  ),
        .rdata                (rdata                ),
        .rresp                (rresp                ),
        .rlast                (rlast                ),
        .rvalid               (rvalid               ),
        .rready               (rready               ),
        .awid                 (awid                 ),
        .awaddr               (awaddr               ),
        .awlen                (awlen                ),
        .awsize               (awsize               ),
        .awburst              (awburst              ),
        .awlock               (awlock               ),
        .awcache              (awcache              ),
        .awprot               (awprot               ),
        .awvalid              (awvalid              ),
        .awready              (awready              ),
        .wid                  (wid                  ),
        .wdata                (wdata                ),
        .wstrb                (wstrb                ),
        .wlast                (wlast                ),
        .wvalid               (wvalid               ),
        .wready               (wready               ),
        .bid                  (bid                  ),
        .bresp                (bresp                ),
        .bvalid               (bvalid               ),
        .bready               (bready               )
    );

    mmu u0_mmu(
    	.addr_i (inst_sram_addr_v ),
        .addr_o (inst_sram_addr   )
    );

    cache_tag_v5 u_icache_tag(
    	.clk        (aclk       ),
        .rst        (~aresetn   ),
        .flush      (1'b0       ),
        .stallreq   (stallreq_from_icache   ),
        .cached     (1'b1     ),
        .sram_en    (inst_sram_en    ),
        .sram_wen   (inst_sram_wen   ),
        .sram_addr  (inst_sram_addr  ),
        .refresh    (icache_refresh    ),
        .miss       (icache_miss       ),
        .axi_raddr  (icache_raddr  ),
        .write_back (icache_write_back ),
        .axi_waddr  (icache_waddr  ),
        .hit        (icache_hit        ),
        .lru        (icache_lru       )
    );

    cache_data_v5 u_icache_data(
    	.clk           (aclk           ),
        .rst           (~aresetn          ),
        .write_back    (1'b0    ),
        .hit           (icache_hit           ),
        .lru           (icache_lru           ),
        .cached        (1'b1        ),
        .sram_en       (inst_sram_en       ),
        .sram_wen      (inst_sram_wen      ),
        .sram_addr     (inst_sram_addr     ),
        .sram_wdata    (inst_sram_wdata    ),
        .sram_rdata    (inst_sram_rdata    ),
        .refresh       (icache_refresh       ),
        .cacheline_new (icache_cacheline_new ),
        .cacheline_old (icache_cacheline_old )
    );
    
    wire [31:0] dcache_temp_rdata;
    wire [31:0] uncache_temp_rdata;
    mmu u1_mmu(
    	.addr_i (data_sram_addr_v ),
        .addr_o (data_sram_addr   ),
        .cache_v(dcache_cached)
    );
    
    cache_tag_v5 u_dcache_tag(
    	.clk        (aclk        ),
        .rst        (~aresetn        ),
        .flush      (flush      ),
        .stallreq   (stallreq_from_dcache   ),
        .cached     (dcache_cached     ),
        .sram_en    (data_sram_en    ),
        .sram_wen   (data_sram_wen   ),
        .sram_addr  (data_sram_addr  ),
        .refresh    (dcache_refresh    ),
        .miss       (dcache_miss       ),
        .axi_raddr  (dcache_raddr  ),
        .write_back (dcache_write_back ),
        .axi_waddr  (dcache_waddr  ),
        .hit        (dcache_hit        ),
        .lru        (dcache_lru        )
    );

    cache_data_v5 u_dcache_data(
    	.clk           (aclk                ),
        .rst           (~aresetn            ),
        .write_back    (dcache_write_back   ),
        .hit           (dcache_hit          ),
        .lru           (dcache_lru          ),
        .cached        (dcache_cached       ),
        .sram_en       (data_sram_en        ),
        .sram_wen      (data_sram_wen       ),
        .sram_addr     (data_sram_addr    ),
        .sram_wdata    (data_sram_wdata     ),
        .sram_rdata    (dcache_temp_rdata   ),
        .refresh       (dcache_refresh      ),
        .cacheline_new (dcache_cacheline_new),
        .cacheline_old (dcache_cacheline_old)
    );

    uncache_tag u_uncache_tag(
    	.clk       (aclk       ),
        .rst       (~aresetn       ),
        .stallreq  (stallreq_from_uncache  ),
        .cached    (dcache_cached    ),
        .sram_en   (data_sram_en   ),
        .sram_wen  (data_sram_wen  ),
        .sram_addr (data_sram_addr ),
        .refresh   (uncache_refresh   ),
        .axi_en    (uncache_en    ),
        .axi_wsel  (uncache_wen  ),
        .axi_addr  (uncache_addr  ),
        .hit       (uncache_hit   )
    );
    
    uncache_data u_uncache_data(
    	.clk        (aclk        ),
        .rst        (~aresetn        ),
        .hit        (uncache_hit        ),
        .cached     (dcache_cached     ),
        .refresh    (uncache_refresh    ),
        .axi_rdata  (uncache_rdata  ),
        .sram_rdata (uncache_temp_rdata )
    );
    
    reg dcache_cached_r;
    always @ (posedge aclk) begin
        dcache_cached_r <= dcache_cached;
    end
    assign data_sram_rdata = dcache_cached_r ? dcache_temp_rdata : uncache_temp_rdata;
    
    
    
endmodule 