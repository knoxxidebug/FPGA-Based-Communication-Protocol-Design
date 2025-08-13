module spi_tb;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    wire sclk;
    wire mosi;
    wire cs;
    wire finish;

    wire [7:0] rx_data;
    wire miso_slave;

    // Instantiate SPI Master
    spi_master master (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .start(start),
        .miso(miso_slave),
        .sclk(sclk),
        .mosi(mosi),
        .cs(cs),
        .finish(finish)
    );

    // Instantiate SPI Slave
    spi_slave slave (
        .clk(clk),  // Ensure the clk signal drives slave's internals
        .rst(rst),
        .mosi(mosi),
        .sclk(sclk),
        .miso(miso_slave),
        .rx_data(rx_data),
        .tx_data(8'b10101010) // Slave's data to transmit
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // Clock period: 10ns

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        start = 0;
        data_in = 8'b11011011; // Data to transmit from master
        #10;

        rst = 0; // Release reset
        #5;

        // Start SPI transfer
        start = 1;
        #10;
        start = 0;

        // Wait for transfer to complete
        wait(finish); // Wait for master's finish signal
        #90;

        $stop; // End simulation
    end
endmodule
