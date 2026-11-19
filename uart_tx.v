module uart_tx #(
    parameter CLKS_PER_BIT = 16 // Adjust based on clock and baud rate
)(
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output reg tx_serial,
    output reg tx_done
);
    reg [3:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; tx_serial <= 1; tx_done <= 0;
        end else begin
            case(state)
                IDLE: begin
                    tx_done <= 0; tx_serial <= 1;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START;
                    end
                end
                START: begin
                    tx_serial <= 0; // Start bit
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; state <= DATA; end
                end
                DATA: begin
                    tx_serial <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else begin bit_index <= 0; state <= STOP; end
                    end
                end
                STOP: begin
                    tx_serial <= 1; // Stop bit
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0; state <= IDLE; tx_done <= 1;
                    end
                end
            endcase
        end
    end
endmodule
