////////////////////////////////////////////////////////////////////////////////--
// Module Name: spi_slave
// Description: SPI Mode 0 Slave responder with tri-state MISO bus control
////////////////////////////////////////////////////////////////////////////////--

module spi_slave #(parameter int WIDTH = 8) (
    input  logic             sclk, mosi, ss,
    output wire              miso, 

    input  logic [WIDTH-1:0] tx_data,
    output logic [WIDTH-1:0] rx_data,
    output logic             rx_done
);

    logic [WIDTH-1:0] shift_tx_data, shift_rx_data;
    logic [2:0]       bit_count;

    // Tri-state buffer driver (high-z when deselected)
    assign miso = (ss) ? 1'bz : shift_tx_data[WIDTH-1];

    // Pre-load MSB on selection (negedge SS)
    always_ff @(negedge ss) begin
        shift_tx_data <= tx_data;
    end

    // Sample MOSI on posedge SCLK
    always_ff @(posedge sclk or posedge ss) begin
        if (ss) begin
            shift_rx_data <= '0;
            bit_count     <= '0;
            rx_done       <= 1'b0;
        end else begin
            shift_rx_data <= {shift_rx_data[WIDTH-2:0], mosi};

            if (bit_count == WIDTH - 1) begin
                bit_count <= '0;
                rx_data   <= {shift_rx_data[WIDTH-2:0], mosi};
                rx_done   <= 1'b1;
            end else begin
                bit_count <= bit_count + 1'b1;
                rx_done   <= 1'b0;
            end
        end
    end

    // Shift next MISO bit on negedge SCLK
    always_ff @(negedge sclk) begin
        if (!ss) shift_tx_data <= shift_tx_data << 1;
    end

endmodule