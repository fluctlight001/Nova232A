module select_top(
    input wire [15:0] ready0,
    input wire [79:0] addr0,
    output wire ready4,
    output wire [4:0] addr4
);
    wire [7:0] ready1;
    wire [39:0] addr1;

    select_unit u00_select_unit(
    	.ready0  (ready0[0]  ),
        .ready1  (ready0[1]  ),
        .addr0   (addr0[4:0]   ),
        .addr1   (addr0[9:5]   ),
        .ready01 (ready1[0] ),
        .addr01  (addr1[4:0]  )
    );

    select_unit u01_select_unit(
    	.ready0  (ready0[2]  ),
        .ready1  (ready0[3]  ),
        .addr0   (addr0[14:10]   ),
        .addr1   (addr0[19:15]   ),
        .ready01 (ready1[1] ),
        .addr01  (addr1[9:5]  )
    );

    select_unit u02_select_unit(
    	.ready0  (ready0[4]  ),
        .ready1  (ready0[5]  ),
        .addr0   (addr0[24:20]   ),
        .addr1   (addr0[29:25]   ),
        .ready01 (ready1[2] ),
        .addr01  (addr1[14:10]  )
    );

    select_unit u03_select_unit(
    	.ready0  (ready0[6]  ),
        .ready1  (ready0[7]  ),
        .addr0   (addr0[34:30]   ),
        .addr1   (addr0[39:35]   ),
        .ready01 (ready1[3] ),
        .addr01  (addr1[19:15]  )
    );

    select_unit u04_select_unit(
    	.ready0  (ready0[8]  ),
        .ready1  (ready0[9]  ),
        .addr0   (addr0[44:40]   ),
        .addr1   (addr0[49:45]   ),
        .ready01 (ready1[4] ),
        .addr01  (addr1[24:20]  )
    );

    select_unit u05_select_unit(
    	.ready0  (ready0[10]  ),
        .ready1  (ready0[11]  ),
        .addr0   (addr0[54:50]   ),
        .addr1   (addr0[59:55]   ),
        .ready01 (ready1[5] ),
        .addr01  (addr1[29:25]  )
    );

    select_unit u06_select_unit(
    	.ready0  (ready0[12]  ),
        .ready1  (ready0[13]  ),
        .addr0   (addr0[64:60]   ),
        .addr1   (addr0[69:65]   ),
        .ready01 (ready1[6] ),
        .addr01  (addr1[34:30]  )
    );

    select_unit u07_select_unit(
    	.ready0  (ready0[14]  ),
        .ready1  (ready0[15]  ),
        .addr0   (addr0[74:70]   ),
        .addr1   (addr0[79:75]   ),
        .ready01 (ready1[7] ),
        .addr01  (addr1[39:35]  )
    );

    wire [3:0] ready2;
    wire [19:0] addr2;

    select_unit u10_select_unit(
    	.ready0  (ready1[0]  ),
        .ready1  (ready1[1]  ),
        .addr0   (addr1[4:0]   ),
        .addr1   (addr1[9:5]   ),
        .ready01 (ready2[0] ),
        .addr01  (addr2[4:0]  )
    );

    select_unit u11_select_unit(
    	.ready0  (ready1[2]  ),
        .ready1  (ready1[3]  ),
        .addr0   (addr1[14:10]   ),
        .addr1   (addr1[19:15]   ),
        .ready01 (ready2[1] ),
        .addr01  (addr2[9:5]  )
    );

    select_unit u12_select_unit(
    	.ready0  (ready1[4]  ),
        .ready1  (ready1[5]  ),
        .addr0   (addr1[24:20]   ),
        .addr1   (addr1[29:25]   ),
        .ready01 (ready2[2] ),
        .addr01  (addr2[14:10]  )
    );

    select_unit u13_select_unit(
    	.ready0  (ready1[6]  ),
        .ready1  (ready1[7]  ),
        .addr0   (addr1[34:30]   ),
        .addr1   (addr1[39:35]   ),
        .ready01 (ready2[3] ),
        .addr01  (addr2[19:15]  )
    );

    wire [1:0] ready3;
    wire [9:0] addr3;

    select_unit u20_select_unit(
    	.ready0  (ready2[0]  ),
        .ready1  (ready2[1]  ),
        .addr0   (addr2[4:0]   ),
        .addr1   (addr2[9:5]   ),
        .ready01 (ready3[0] ),
        .addr01  (addr3[4:0]  )
    );

    select_unit u21_select_unit(
    	.ready0  (ready2[2]  ),
        .ready1  (ready2[3]  ),
        .addr0   (addr2[14:10]   ),
        .addr1   (addr2[19:15]   ),
        .ready01 (ready3[1] ),
        .addr01  (addr3[9:5]  )
    );

    // wire ready4;
    // wire [4:0] addr4;

    select_unit u30_select_unit(
    	.ready0  (ready3[0]  ),
        .ready1  (ready3[1]  ),
        .addr0   (addr3[4:0]   ),
        .addr1   (addr3[9:5]   ),
        .ready01 (ready4 ),
        .addr01  (addr4[4:0]  )
    );


    
endmodule