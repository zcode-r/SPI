////////////////////////////////////////////////////////////////////////////////--
// Module Name: spi_master
// Description: SPI Mode 0 (CPOL=0, CPHA=0) Master with active-low Chip Select
////////////////////////////////////////////////////////////////////////////////--

module spi_master #(
    parameter int WIDTH = 8
)(
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] tx_data,
    output logic [WIDTH-1:0] rx_data,
    input  logic             start,
    input  logic [1:0]       slave,
    output logic             ready,
    
    output logic             sclk, mosi,
    output logic [2:0]       ss,
    input  logic             miso
);

    typedef enum logic [1:0] {
        IDLE, START, TRANSFER, STOP
    } state_e;

    state_e state;

    logic [3:0]       count;
    logic [2:0]       bit_count;
    logic [WIDTH-1:0] shift_tx_data, shift_rx_data;

    localparam int clk_div = 5;

    // Active-Low Chip Select Decoder
    always_comb begin
        if (state == IDLE) ss = 3'b111;
        else begin
            case (slave) 
                2'b00:   ss = 3'b110; // Select Slave 0
                2'b01:   ss = 3'b101; // Select Slave 1
                2'b10:   ss = 3'b011; // Select Slave 2
                default: ss = 3'b111;
            endcase
        end
    end

    // Master FSM Engine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            rx_data       <= '0;
            ready         <= 1'b1;
            count         <= '0;
            bit_count     <= '0;
            shift_tx_data <= '0;
            shift_rx_data <= '0;
            sclk          <= 1'b0;
            mosi          <= 1'b0;
        end else begin
            case (state) 
                IDLE: begin 
                    ready     <= 1'b1;
                    sclk      <= 1'b0;
                    mosi      <= 1'b0;
                    count     <= '0;
                    bit_count <= '0;

                    if (start) begin
                        ready         <= 1'b0;
                        shift_tx_data <= tx_data;
                        state         <= START;
                    end
                end

                START: begin
                    mosi <= shift_tx_data[WIDTH-1]; // Drive MSB before clock edges

                    if (count == clk_div - 1) begin
                        count <= '0;
                        state <= TRANSFER;
                    end else count <= count + 1'b1;
                end

                TRANSFER: begin
                    if (count == clk_div - 1) begin
                        count <= '0;
                        sclk  <= ~sclk;

                        if (sclk == 1'b1) begin
                            if (bit_count == WIDTH - 1) begin
                                bit_count <= '0;
                                sclk      <= 1'b0;
                                state     <= STOP;
                            end else begin
                                bit_count     <= bit_count + 1'b1;
                                shift_tx_data <= shift_tx_data << 1;
                                mosi          <= shift_tx_data[WIDTH-2];
                            end
                        end else begin
                            shift_rx_data <= {shift_rx_data[WIDTH-2:0], miso};
                        end
                    end else count <= count + 1'b1;
                end

                STOP: begin
                    mosi    <= 1'b0;
                    sclk    <= 1'b0;
                    rx_data <= shift_rx_data;

                    if (count == clk_div - 1) begin
                        count <= '0;
                        state <= IDLE;
                    end else count <= count + 1'b1;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule