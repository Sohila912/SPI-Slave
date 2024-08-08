module SPI_Slave (MOSI,temp,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);
    //defining the 5 states using One-Hot encoding....
    parameter IDLE = 5'b00001;
    parameter WRITE = 5'b00010 ;
    parameter CHK_CMD = 5'b00100 ;
    parameter READ_DATA = 5'b01000;
    parameter READ_ADD = 5'b10000;

    //defining inputs and outputs.....................
    input MOSI,SS_n,clk,rst_n,tx_valid;
    input [7:0] tx_data;
    output reg rx_valid;
    //output MISO;
    output reg [9:0] rx_data;
    reg flag1;

    //defining internal signals........................
    //TO-DO: add FSM encoding line (* fsm_encoding = "one_hot" *)
    (* fsm_encoding = "one_hot" *) reg [4:0] cs,ns;
    reg [3:0] counter; //used to count to 8 to know when to stop
    reg inc = 0;           //when incremented from 0 to 1 then read data not address
    reg [9:0] writebus,readbus;
    reg [7:0] misobus;
    output reg temp;

    //State Memory.....................................
    always @(posedge clk) begin
        if (~rst_n) begin
            cs<=IDLE;
            // inc<=0;
            
            
        end
        else begin
            cs<=ns;
        end
    end

    //Next State Logic....................................
    always @(*) begin
        
        case (cs)
            IDLE: begin
//                counter=0;
//                writebus=10'b0;
//                readbus=10'b0;
                if (~SS_n) 
                    ns=CHK_CMD;
                else
                    ns=IDLE;
            end
            WRITE: begin
            if (SS_n) begin 
                ns=IDLE;
                
            end
            else begin
                ns=WRITE;
            end
            end
            READ_ADD:begin
            
                if (SS_n) 
                   ns=IDLE;
                else
                   ns=READ_ADD;
            end
            READ_DATA:begin 
           
            if (SS_n) 
                ns=IDLE;
            else
                ns=READ_DATA;
            end
            CHK_CMD: begin
               
            if ( (~SS_n) && (~MOSI) ) 
                ns=WRITE;
            else if ((~SS_n) && (MOSI)) begin
                if (~inc)
                    ns=READ_ADD;
                else
                    ns=READ_DATA;   
                end 
            else
                ns=IDLE;
            end 
            default: begin
                ns= IDLE; 
                
            end
        endcase
    end
   
    //Output Logic depends on current state and input.....
    always @(posedge clk) begin
        if (~SS_n) begin
            if(cs == IDLE) begin
                rx_valid<=0;
                rx_data<=0;
                counter<=0;
                writebus<=10'b0;
                readbus<=10'b0;
                
                
            end
            else
            if (cs==WRITE) begin
                //first check if the write data/address is complete
                if (counter==4'b1010) begin  
                    rx_data<=writebus;
                    rx_valid<=1;
                    counter<=0;
                    writebus<=0;
                end
                else begin
                    writebus<= {writebus[8:0],MOSI};
                    counter<=counter+1;
                end
            end
            else if (cs==READ_ADD) begin
               //first check if the read address is complete
                if (counter==4'b1010) begin  
                    rx_data<=readbus;
                    rx_valid<=1;
                    counter<=0;
                    readbus<=0;
                end
                else begin
                    readbus<= {readbus[8:0],MOSI};
                    counter<=counter+1;
                end 
            end
            else if (cs==READ_DATA) begin
                //first check if the read data is complete
                // if (tx_valid) begin
                //     misobus <= tx_data; // Capture tx_data in misobus                           
                // end   
                //  else begin
                    if (counter==4'b1010) begin  
                        rx_data<=readbus;
                        rx_valid<=1;
                        counter<=0;
                        readbus<=0;
                    end
                    else begin
                        readbus<= {readbus[8:0],MOSI};
                        counter<=counter+1;       
                    end  
                //  end       
                                             
                    end 
            else begin
                rx_valid<=0;
                rx_data<=0;
            end
        end
        else begin
            rx_valid<=0;
            rx_data<=0;
        end
    end

    always @(posedge clk) begin
        if((~rst_n) || (cs == IDLE && ~SS_n)) begin
            flag1<=0;
            misobus <= 8'b0;
            temp<=0;
        end
        else if(cs == READ_DATA && tx_valid ) begin
            if(flag1 == 0) begin
            misobus <= tx_data;

            flag1<=1;
            end
            else if(flag1 == 1) begin
                temp<=misobus[7];
                misobus <= {misobus[6:0],1'b0};
                if(misobus == 8'b0) begin
                    flag1<=0;
                end
                else begin
                    flag1<=1;
                end
            end 
            
        end
    end
    //assign MISO=temp;
    always @(posedge clk) begin
        if(~rst_n) begin
            inc<=0;
        end
        else begin
            if(cs==READ_ADD )
                inc<=1;
                else if(cs==READ_DATA)
                    inc<=0;
        end
    end

endmodule