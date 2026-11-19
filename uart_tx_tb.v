module uart_tx_tb;
    reg clk, reset, tx_start;
    reg [7:0] tx_data;
    wire tx_serial, tx_done;

    uart_tx #(16) uut (clk, reset, tx_start, tx_data, tx_serial, tx_done);

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; tx_start = 0; tx_data = 8'h00;
        #10 reset = 0;
        #10 tx_data = 8'h55; // 01010101 in binary
        tx_start = 1; #10; tx_start = 0;
        wait(tx_done);
        #20 $finish;
    end
endmodule
