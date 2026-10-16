////////////////////////////////////////////////////////////////////////////////--
// Module Name: spi_top
// Description: Top wrapper instantiating SPI Master & 3 Slave peripherals
////////////////////////////////////////////////////////////////////////////////--

module spi_top #(
    parameter int WIDTH = 8
)(
    input  logic             clk, reset,

    input  logic [WIDTH-1:0] master_tx_data,
    input  logic [1:0]       target_slave,
    input  logic             start,
    output logic [WIDTH-1:0] master_rx_data,
    output logic             ready,

    input  logic [WIDTH-1:0] slave0_tx_data,
    input  logic [WIDTH-1:0] slave1_tx_data,
    input  logic [WIDTH-1:0] slave2_tx_data,

    output logic [WIDTH-1:0] slave0_rx_data,
    output logic [WIDTH-1:0] slave1_rx_data,
    output logic [WIDTH-1:0] slave2_rx_data,
    output logic             slave0_done,
    output logic             slave1_done,
    output logic             slave2_done
);

    logic       sclk_bus;
    logic       mosi_bus;
    wire        miso_bus; 
    logic [2:0] ss_bus;

    spi_master #(.WIDTH(WIDTH)) master_inst (
        .clk     (clk),
        .reset   (reset),
        .tx_data (master_tx_data),
        .slave   (target_slave),
        .start   (start),
        .rx_data (master_rx_data),
        .ready   (ready),
        .sclk    (sclk_bus),
        .mosi    (mosi_bus),
        .miso    (miso_bus),
        .ss      (ss_bus)
    );

    spi_slave #(.WIDTH(WIDTH)) slave0_inst (
        .sclk    (sclk_bus),
        .mosi    (mosi_bus),
        .miso    (miso_bus),
        .ss      (ss_bus[0]),
        .tx_data (slave0_tx_data),
        .rx_data (slave0_rx_data),
        .rx_done (slave0_done)
    );

    spi_slave #(.WIDTH(WIDTH)) slave1_inst (
        .sclk    (sclk_bus),
        .mosi    (mosi_bus),
        .miso    (miso_bus),
        .ss      (ss_bus[1]),
        .tx_data (slave1_tx_data),
        .rx_data (slave1_rx_data),
        .rx_done (slave1_done)
    );

    spi_slave #(.WIDTH(WIDTH)) slave2_inst (
        .sclk    (sclk_bus),
        .mosi    (mosi_bus),
        .miso    (miso_bus),
        .ss      (ss_bus[2]),
        .tx_data (slave2_tx_data),
        .rx_data (slave2_rx_data),
        .rx_done (slave2_done)
    );

endmodule