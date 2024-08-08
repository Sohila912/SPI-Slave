module RAM (
    input [9:0] din,
    input clk,
    input rst_n,
    input rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);
    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;

    reg [7:0] mem_spi [MEM_DEPTH-1:0];
    reg [ADDR_SIZE-1:0] write_addr; // write address
    reg [ADDR_SIZE-1:0] read_addr;  // read address

    always @(posedge clk) begin
        if (!rst_n) begin
            write_addr <= 0;
            read_addr <= 0;
            tx_valid <= 0;
            dout <= 0;
            
        end else if (rx_valid) begin
            case (din[9:8])
                2'b00: begin
                    // write address setup
                    write_addr <= din[7:0];
                    tx_valid <= 0;
                end
                2'b01: begin
                    // write data to memory
                    mem_spi[write_addr] <= din[7:0];
                    tx_valid <= 0;
                end
                2'b10: begin
                    // read address setup
                    read_addr <= din[7:0];
                end
                2'b11: begin
                    // read data from memory
                    dout <= mem_spi[read_addr];
                    tx_valid <= 1;
                end
                default: begin
                    tx_valid <= 0;
                end
            endcase
        end else begin
            tx_valid <= 0;
            dout <= 0;
        end
    end
endmodule