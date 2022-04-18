module DEMUX_16(
    input wire [47:0] sel,
    input wire [15:0] din,
    output wire [15:0] dout7, dout6, dout5, dout4, dout3, dout2, dout1, dout0
);

        DEMUX_1_8 u0_DEMUX_1_8(
    	.sel   (sel[2:0] ),
        .din   (din[0]   ),
        .dout7 (dout7[0] ),
        .dout6 (dout6[0] ),
        .dout5 (dout5[0] ),
        .dout4 (dout4[0] ),
        .dout3 (dout3[0] ),
        .dout2 (dout2[0] ),
        .dout1 (dout1[0] ),
        .dout0 (dout0[0] )
    );
    DEMUX_1_8 u1_DEMUX_1_8(
    	.sel   (sel[5:3] ),
        .din   (din[1]   ),
        .dout7 (dout7[1] ),
        .dout6 (dout6[1] ),
        .dout5 (dout5[1] ),
        .dout4 (dout4[1] ),
        .dout3 (dout3[1] ),
        .dout2 (dout2[1] ),
        .dout1 (dout1[1] ),
        .dout0 (dout0[1] )
    );
    DEMUX_1_8 u2_DEMUX_1_8(
    	.sel   (sel[8:6] ),
        .din   (din[2]   ),
        .dout7 (dout7[2] ),
        .dout6 (dout6[2] ),
        .dout5 (dout5[2] ),
        .dout4 (dout4[2] ),
        .dout3 (dout3[2] ),
        .dout2 (dout2[2] ),
        .dout1 (dout1[2] ),
        .dout0 (dout0[2] )
    );
    DEMUX_1_8 u3_DEMUX_1_8(
    	.sel   (sel[11:9] ),
        .din   (din[3]   ),
        .dout7 (dout7[3] ),
        .dout6 (dout6[3] ),
        .dout5 (dout5[3] ),
        .dout4 (dout4[3] ),
        .dout3 (dout3[3] ),
        .dout2 (dout2[3] ),
        .dout1 (dout1[3] ),
        .dout0 (dout0[3] )
    );
    DEMUX_1_8 u4_DEMUX_1_8(
    	.sel   (sel[14:12] ),
        .din   (din[4]   ),
        .dout7 (dout7[4] ),
        .dout6 (dout6[4] ),
        .dout5 (dout5[4] ),
        .dout4 (dout4[4] ),
        .dout3 (dout3[4] ),
        .dout2 (dout2[4] ),
        .dout1 (dout1[4] ),
        .dout0 (dout0[4] )
    );
    DEMUX_1_8 u5_DEMUX_1_8(
    	.sel   (sel[17:15] ),
        .din   (din[5]   ),
        .dout7 (dout7[5] ),
        .dout6 (dout6[5] ),
        .dout5 (dout5[5] ),
        .dout4 (dout4[5] ),
        .dout3 (dout3[5] ),
        .dout2 (dout2[5] ),
        .dout1 (dout1[5] ),
        .dout0 (dout0[5] )
    );
    DEMUX_1_8 u6_DEMUX_1_8(
    	.sel   (sel[20:18] ),
        .din   (din[6]   ),
        .dout7 (dout7[6] ),
        .dout6 (dout6[6] ),
        .dout5 (dout5[6] ),
        .dout4 (dout4[6] ),
        .dout3 (dout3[6] ),
        .dout2 (dout2[6] ),
        .dout1 (dout1[6] ),
        .dout0 (dout0[6] )
    );
    DEMUX_1_8 u7_DEMUX_1_8(
    	.sel   (sel[23:21] ),
        .din   (din[7]   ),
        .dout7 (dout7[7] ),
        .dout6 (dout6[7] ),
        .dout5 (dout5[7] ),
        .dout4 (dout4[7] ),
        .dout3 (dout3[7] ),
        .dout2 (dout2[7] ),
        .dout1 (dout1[7] ),
        .dout0 (dout0[7] )
    );
    DEMUX_1_8 u8_DEMUX_1_8(
    	.sel   (sel[26:24] ),
        .din   (din[8]   ),
        .dout7 (dout7[8] ),
        .dout6 (dout6[8] ),
        .dout5 (dout5[8] ),
        .dout4 (dout4[8] ),
        .dout3 (dout3[8] ),
        .dout2 (dout2[8] ),
        .dout1 (dout1[8] ),
        .dout0 (dout0[8] )
    );
    DEMUX_1_8 u9_DEMUX_1_8(
    	.sel   (sel[29:27] ),
        .din   (din[9]   ),
        .dout7 (dout7[9] ),
        .dout6 (dout6[9] ),
        .dout5 (dout5[9] ),
        .dout4 (dout4[9] ),
        .dout3 (dout3[9] ),
        .dout2 (dout2[9] ),
        .dout1 (dout1[9] ),
        .dout0 (dout0[9] )
    );
    DEMUX_1_8 u10_DEMUX_1_8(
    	.sel   (sel[32:30] ),
        .din   (din[10]   ),
        .dout7 (dout7[10] ),
        .dout6 (dout6[10] ),
        .dout5 (dout5[10] ),
        .dout4 (dout4[10] ),
        .dout3 (dout3[10] ),
        .dout2 (dout2[10] ),
        .dout1 (dout1[10] ),
        .dout0 (dout0[10] )
    );
    DEMUX_1_8 u11_DEMUX_1_8(
    	.sel   (sel[35:33] ),
        .din   (din[11]   ),
        .dout7 (dout7[11] ),
        .dout6 (dout6[11] ),
        .dout5 (dout5[11] ),
        .dout4 (dout4[11] ),
        .dout3 (dout3[11] ),
        .dout2 (dout2[11] ),
        .dout1 (dout1[11] ),
        .dout0 (dout0[11] )
    );
    DEMUX_1_8 u12_DEMUX_1_8(
    	.sel   (sel[38:36] ),
        .din   (din[12]   ),
        .dout7 (dout7[12] ),
        .dout6 (dout6[12] ),
        .dout5 (dout5[12] ),
        .dout4 (dout4[12] ),
        .dout3 (dout3[12] ),
        .dout2 (dout2[12] ),
        .dout1 (dout1[12] ),
        .dout0 (dout0[12] )
    );
    DEMUX_1_8 u13_DEMUX_1_8(
    	.sel   (sel[41:39] ),
        .din   (din[13]   ),
        .dout7 (dout7[13] ),
        .dout6 (dout6[13] ),
        .dout5 (dout5[13] ),
        .dout4 (dout4[13] ),
        .dout3 (dout3[13] ),
        .dout2 (dout2[13] ),
        .dout1 (dout1[13] ),
        .dout0 (dout0[13] )
    );
    DEMUX_1_8 u14_DEMUX_1_8(
    	.sel   (sel[44:42] ),
        .din   (din[14]   ),
        .dout7 (dout7[14] ),
        .dout6 (dout6[14] ),
        .dout5 (dout5[14] ),
        .dout4 (dout4[14] ),
        .dout3 (dout3[14] ),
        .dout2 (dout2[14] ),
        .dout1 (dout1[14] ),
        .dout0 (dout0[14] )
    );
    DEMUX_1_8 u15_DEMUX_1_8(
    	.sel   (sel[47:45] ),
        .din   (din[15]   ),
        .dout7 (dout7[15] ),
        .dout6 (dout6[15] ),
        .dout5 (dout5[15] ),
        .dout4 (dout4[15] ),
        .dout3 (dout3[15] ),
        .dout2 (dout2[15] ),
        .dout1 (dout1[15] ),
        .dout0 (dout0[15] )
    );
    
endmodule