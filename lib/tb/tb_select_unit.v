module tb_select_unit();
    reg ready0, ready1;
    reg [4:0] addr0, addr1;
    wire ready01;
    wire [4:0] addr01;
    select_unit u_select_unit(
    	.ready0  (ready0  ),
        .ready1  (ready1  ),
        .addr0   (addr0   ),
        .addr1   (addr1   ),
        .ready01 (ready01 ),
        .addr01  (addr01  )
    );

    initial begin
        addr0 = 5'b01011;
        addr1 = 5'b10011;
        ready0 = 1'b1;
        ready1 = 1'b1;
    end

    always # 10 begin
        addr0 = addr0 + 1'b1;
    end

    always # 30 begin
        ready1 = ~ready1;
    end

    always # 40 begin
        ready0 = ~ready0;
    end
    
endmodule