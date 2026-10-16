////////////////////////////////////////////////////////////////////////////////--
// Module Name: spi_tb
// Description: Self-checking testbench for full-duplex Master-Slave transfers
////////////////////////////////////////////////////////////////////////////////--

`timescale 1ns/1ps

module spi_tb;

    localparam int WIDTH = 8;

    logic             clk, reset;
    logic [WIDTH-1:0] master_tx_data;
    logic [1:0]       target_slave;
    logic             start;
    logic [WIDTH-1:0] master_rx_data;
    logic             ready;

    logic [WIDTH-1:0] slave0_tx_data, slave1_tx_data, slave2_tx_data;
    logic [WIDTH-1:0] slave0_rx_data, slave1_rx_data, slave2_rx_data;
    logic             slave0_done, slave1_done, slave2_done;

    // Instantiate Top DUT
    spi_top #(.WIDTH(WIDTH)) dut (
        .*
    );

    // 50 MHz Clock
    always #10 clk = ~clk;

    // Test Transaction Task
    task automatic test_spi_transfer(
        input [1:0]       slave_id,
        input [WIDTH-1:0] m_data,
        input [WIDTH-1:0] s_data
    );
        begin
            wait(ready == 1'b1);
            @(posedge clk);
            target_slave   = slave_id;
            master_tx_data = m_data;

            case (slave_id)
                2'b00: slave0_tx_data = s_data;
                2'b01: slave1_tx_data = s_data;
                2'b10: slave2_tx_data = s_data;
            endcase

            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            $display("\n[SPI START] Target Slave: %0d | Master Tx: 8'h%h | Slave Tx: 8'h%h", slave_id, m_data, s_data);

            wait(ready == 1'b1);
            @(posedge clk);

            // Verify Full-Duplex Data Swap
            if (master_rx_data == s_data) begin
                $display(">>> [RESULT] SUCCESS! Master received Slave's data: 8'h%h <<<", master_rx_data);
            end else begin
                $display(">>> [RESULT] ERROR! Master expected 8'h%h but got 8'h%h <<<", s_data, master_rx_data);
            end
            $display("-------------------------------------------------------------------");
        end
    endtask

    // Execution Logic
    initial begin
        clk            = 1'b0;
        reset          = 1'b1;
        start          = 1'b0;
        target_slave   = 2'b00;
        master_tx_data = 8'h00;
        slave0_tx_data = 8'h11;
        slave1_tx_data = 8'h22;
        slave2_tx_data = 8'h33;

        #40;
        reset = 1'b0;
        #40;

        $display("================ STARTING SPI BUS TRANSACTIONS ================");

        // Test 1: Exchange data with Slave 0
        test_spi_transfer(2'b00, 8'hA5, 8'h5A);

        // Test 2: Exchange data with Slave 1
        test_spi_transfer(2'b01, 8'h3C, 8'hC3);

        // Test 3: Exchange data with Slave 2
        test_spi_transfer(2'b10, 8'hFF, 8'h00);

        $display("================ ALL TESTS COMPLETED ================\n");
        $finish;
    end

    // Dump VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, spi_tb);
    end

endmodule