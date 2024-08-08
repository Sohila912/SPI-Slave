module finalSPI (MOSI,miso,SS_n,clk,rst_n);
    //defining inputs and outputs...........
    input MOSI,SS_n,clk,rst_n;
    output  miso;
    //defining internal signals.............
    wire [9:0] din;
    wire datain_v,dataout_v;  //rx_valid and tx_valid
    wire [7:0] dout;
    //wire innermiso;

    //inistantiating SPI_Slave block
    SPI_Slave SPIblock (.MOSI(MOSI),.temp(miso),.SS_n(SS_n),.clk(clk),.rst_n(rst_n),.rx_data(din),.rx_valid(datain_v),.tx_data(dout),.tx_valid(dataout_v));

    //inistantiating RAM block
    RAM #(256,8) ramblock ( .din(din),.clk(clk),.rst_n(rst_n),.rx_valid(datain_v),.dout(dout),.tx_valid(dataout_v));


endmodule