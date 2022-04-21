module tb_select_top(

);
    reg [15:0] ready0;
    reg [79:0] addr0;
    wire ready4;
    wire [4:0] addr4;
    select_top u_select_top(
    	.ready0 (ready0 ),
        .addr0  (addr0  ),
        .ready4 (ready4 ),
        .addr4  (addr4  )
    );

    initial begin
        ready0 = 16'b1010101010101010;
        addr0[4:0] = 5'd8;
        addr0[9:5] = 5'd9;
        addr0[14:10] = 5'd10;
        addr0[19:15] = 5'd11;
        addr0[24:20] = 5'd12;
        addr0[29:25] = 5'd13;
        addr0[34:30] = 5'd14;
        addr0[39:35] = 5'd15;
        addr0[44:40] = 5'd16;
        addr0[49:45] = 5'd17;
        addr0[54:50] = 5'd18;
        addr0[59:55] = 5'd19;
        addr0[64:60] = 5'd20;
        addr0[69:65] = 5'd21;
        addr0[74:70] = 5'd22;
        addr0[79:75] = 5'd23;
    end
    

    always #10 begin
        ready0 = ready0 + 1'b1;
    end
endmodule