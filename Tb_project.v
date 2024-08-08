`timescale 1ns / 1ps

module tb_finalSPI();

    reg MOSI, SS_n, clk, rst_n;
    wire MISO;

    finalSPI uut (.MOSI(MOSI), .miso(MISO), .SS_n(SS_n), .clk(clk), .rst_n(rst_n));

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // SPI Clock generation
    reg SCLK;
    initial begin
        SCLK = 0;
        forever #10 SCLK = ~SCLK; // 50MHz SCLK (25MHz SPI clock frequency)
    end

    // Task to send data to SPI Slave
    task send_spi_data;
        input [9:0] data;
        integer i;
        begin
            SS_n = 0; // Select the slave to communicate
            for (i = 9; i >= 0; i = i - 1) begin
                @(negedge SCLK) MOSI = data[i];
            end
            @(negedge SCLK);
            SS_n = 1; // No communication
        end
    endtask

    initial begin
        // Initialize signals
        MOSI = 0;
        SS_n = 1;
        rst_n = 0;

        // Apply reset
        @(posedge clk);
        rst_n = 1;

        // Wait for reset to de-assert
        @(posedge clk);

        // Test case 1: Write address 0x00
        send_spi_data(10'b0000000000); // Write address 0
        @(posedge clk);

        // Test case 2: Write data 0xAA to address 0x00
        send_spi_data(10'b0100101010); // Write data 0xAA to address 0x00
        @(posedge clk);

        // Test case 3: Read address 0x00
        send_spi_data(10'b1000000000); // Read address 0
        @(posedge clk);

        // Test case 4: Read data from address 0x00
        send_spi_data(10'b1100000000); // Read data from address 0
        @(posedge clk);

        // Test case 5: Write address 0x01
        send_spi_data(10'b0000000001); // Write address 1
        @(posedge clk);

        // Test case 6: Write data 0x55 to address 0x01
        send_spi_data(10'b0100010101); // Write data 0x55 to address 0x01
        @(posedge clk);

        // Test case 7: Read address 0x01
        send_spi_data(10'b1000000001); // Read address 1
        @(posedge clk);

        // Test case 8: Read data from address 0x01
        send_spi_data(10'b1100000000); // Read data from address 1
        @(posedge clk);

        // Test case 9: Write address 0x02
        send_spi_data(10'b0000000010); // Write address 2
        @(posedge clk);

        // Test case 10: Write data 0xFF to address 0x02
        send_spi_data(10'b0100111111); // Write data 0xFF to address 2
        @(posedge clk);

        // Test case 11: Read address 0x02
        send_spi_data(10'b1000000010); // Read address 2
        @(posedge clk);

        // Test case 12: Read data from address 0x02
        send_spi_data(10'b1100000000); // Read data from address 2
        @(posedge clk);

        // Test case 13: Write address 0x03
        send_spi_data(10'b0000000011); // Write address 3
        @(posedge clk);

        // Test case 14: Write data 0x00 to address 0x03
        send_spi_data(10'b0100000000); // Write data 0x00 to address 3
        @(posedge clk);

        // Test case 15: Read address 0x03
        send_spi_data(10'b1000000011); // Read address 3
        @(posedge clk);

        // Test case 16: Read data from address 0x03
        send_spi_data(10'b1100000000); // Read data from address 3
        @(posedge clk);

        // Test case 17: Write address 0x04
        send_spi_data(10'b0000000100); // Write address 4
        @(posedge clk);

        // Test case 18: Write data 0x3C to address 0x04
        send_spi_data(10'b0100111100); // Write data 0x3C to address 4
        @(posedge clk);

        // Test case 19: Read address 0x04
        send_spi_data(10'b1000000100); // Read address 4
        @(posedge clk);

        // Test case 20: Read data from address 0x04
        send_spi_data(10'b1100000000); // Read data from address 4
        @(posedge clk);

        // Test case 21: Reset the design
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // Test case 22: Write address 0x05
        send_spi_data(10'b0000000101); // Write address 5
        @(posedge clk);

        // Test case 23: Write data 0x77 to address 0x05
        send_spi_data(10'b0100010111); // Write data 0x77 to address 5
        @(posedge clk);

        // Test case 24: Read address 0x05
        send_spi_data(10'b1000000101); // Read address 5
        @(posedge clk);

        // Test case 25: Read data from address 0x05
        send_spi_data(10'b1100000000); // Read data from address 5
        @(posedge clk);

        // Test case 26: Edge case: writing and reading zero address and data
        send_spi_data(10'b0000000000); // Write address 0
        @(posedge clk);
        send_spi_data(10'b0100000000); // Write data 0 to address 0
        @(posedge clk);
        send_spi_data(10'b1000000000); // Read address 0
        @(posedge clk);
        send_spi_data(10'b1100000000); // Read data from address 0
        @(posedge clk);

        $stop;
    end
endmodule
