module spi_master(
    input wire clk, // internal clock signal
    input wire rst, // reset signal
    input wire [7:0] data_in, // data input signal
    input wire start, // initiate SPI master
    input wire miso, // master in slave out pin
    output reg sclk, // SPI clock
    output reg mosi, // master out slave in pin
    output reg cs, // chip select pin
    output reg finish // data transfer complete    
);
    reg [3:0] bit_counter = 0; // bit counter
    reg [7:0] shift_reg; // shift register to load data

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0;
            mosi <= 0;
            cs <= 1;
            bit_counter <= 0;
            shift_reg <= 0;
            finish <= 0;
        end else begin
            if (start) begin
                cs <= 0; // Activate chip select
                shift_reg <= data_in; // Load data into shift register
                finish <= 0; // Clear finish signal
            end

            if (~cs) begin
                sclk <= ~sclk; // spi clock toggle feature inbuilt
                
                if (sclk == 0) begin // falling edge of sclk
                    mosi <= shift_reg[7]; // MSB
                    shift_reg <= {shift_reg[6:0], miso}; // shift data 
                    bit_counter <= bit_counter + 1;
                end

                if (bit_counter == 9) begin
                    cs <= 1; // deactivate chip select
                    finish <= 1; // signal transfer complete
                    bit_counter <= 0;
                end
            end
        end
    end
endmodule

module spi_slave (
    input wire clk, // internal clock
    input wire rst, // reset signal
    input wire mosi, // master out slave in pin
    input wire sclk, // SPI clock
    output reg miso, // master in slave out pin
    output reg [7:0] rx_data, // received data
    input wire [7:0] tx_data // data to transmit
);
    reg [3:0] bit_counter = 0; // bit counter
    reg [7:0] shift_reg; // shift register

    always @(posedge sclk or posedge rst) begin
        if (rst) begin
            bit_counter <= 0;
            shift_reg <= 0;
            miso <= 0;
        end else begin
            // Shift data from master into shift register
            shift_reg <= {shift_reg[6:0],mosi};
            bit_counter <= bit_counter + 1;

            // Send data to master
            miso <= tx_data[7 - bit_counter];
            rx_data <= shift_reg; // store recieved data

            if (bit_counter == 7) begin
                bit_counter <= 0; // resetting the counter
            end
        end
    end
endmodule
