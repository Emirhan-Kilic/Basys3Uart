`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 02:38:31 AM
// Design Name: 
// Module Name: recieverStage3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module recieverStage3(

    input logic reset,
    input logic clk,
    input logic RX,
    output logic [7:0] RXBUF [3:0]

    );


    reg [7:0] recievedLight;

    reg [1:0] nStage;
    reg [1:0] pStage;

    reg RXBUF_load;
    reg RXBUF_clr;
    reg counter_clr;
    reg recieving_sgnl;
    reg countbit_mt_9;
    reg countbitCompare9_clr;

    reg [3:0] countBits;
    reg [9:0] recieveingReg;

    reg recieveingReg_clr;




    reg [16:0] baudRateReg;
    reg baudratePerOut;
    reg baudRateReg_clr;

    always_ff @(posedge clk) begin 

        if (reset) pStage <= 2'b00;
        else pStage <= nStage;   


        if (baudRateReg == 867) begin
            baudratePerOut <= 1'b1;
            baudRateReg <= 0;
        end else begin
            baudratePerOut <= 1'b0;
            baudRateReg <= baudRateReg + 1;
        end

        if(baudRateReg_clr) begin
            baudRateReg <= 0;
        end



        if (recieveingReg_clr) begin
            recieveingReg <= 0;
        end

        if (countbitCompare9_clr) begin

            countbit_mt_9 <= 1'b0;

        end

        if (RXBUF_clr) begin
            RXBUF[0] <= 8'b00000000;
            RXBUF[1] <= 8'b00000000;
            RXBUF[2] <= 8'b00000000;
            RXBUF[3] <= 8'b00000000;
        end
        
        else if (RXBUF_load) begin 
            RXBUF[3] <= RXBUF[2];
            RXBUF[2] <= RXBUF[1];
            RXBUF[1] <= RXBUF[0];
            RXBUF[0] <= recieveingReg[8:1];
            $display("LOADED RXBUF, ", recieveingReg[8:1], " ", RXBUF[0], " ", RXBUF[1]," ", RXBUF[2]," ", RXBUF[3]);
        end


     
        if (recieving_sgnl) begin
            if (countBits > 9 ) countbit_mt_9 <= 1'b1; 
            else begin
                countbit_mt_9 <= 1'b0;

                if (baudRateReg == 433) begin 
                    recieveingReg[countBits] <= RX;
                end

                                
                if (baudratePerOut) begin
                    countBits <= countBits + 1;
                    baudRateReg <= 0;
                end


            end

        end

        if (counter_clr) begin
            countBits <= 0;
        end 

    end

    always @(RXBUF[3]) begin
        recievedLight <= RXBUF[3];
    end 


    // 00 init
    // 01 wait
    // 10 recieve
    always_comb begin

        case (pStage)
            2'b00: begin
                nStage = 2'b01;
            end
            2'b01: begin
                if (!RX) nStage = 2'b10;
                else nStage = 2'b01; 

            end
            2'b10: begin
                if (countbit_mt_9) nStage = 2'b11;
                else nStage = 2'b10;

            end
            2'b11: begin
                nStage = 2'b01;
            end
            default: nStage = 2'b00;
            
        endcase
    end


    // 00 init
    // 01 wait
    // 10 recieve


always_comb begin
        case (pStage)
            2'b00: begin
                RXBUF_clr = 1'b1;                                
                RXBUF_load = 1'b0;
                recieving_sgnl = 1'b0;
                counter_clr = 1'b1;
                countbitCompare9_clr = 1'b1;
                recieveingReg_clr = 1'b1; 
                baudRateReg_clr = 1'b1;
                                          
            end
            2'b01: begin
                RXBUF_clr = 1'b0;
                RXBUF_load = 1'b0;                                
                recieving_sgnl = 1'b0;                                
                counter_clr = 1'b1;                                
                countbitCompare9_clr = 1'b1;
                recieveingReg_clr = 1'b0; 
                baudRateReg_clr = 1'b1;

            end
            2'b10: begin
                RXBUF_clr = 1'b0;
                RXBUF_load = 1'b0;                                
                recieving_sgnl = 1'b1;                                
                counter_clr = 1'b0;                                
                countbitCompare9_clr = 1'b0;
                recieveingReg_clr = 1'b0; 
                baudRateReg_clr = 1'b0;

            end

            2'b11: begin

                RXBUF_clr = 1'b0;                                
                RXBUF_load = 1'b1;
                recieving_sgnl = 1'b0;
                counter_clr = 1'b1;
                countbitCompare9_clr = 1'b1;
                recieveingReg_clr = 1'b1; 
                baudRateReg_clr = 1'b1;            
            end

        endcase
end


endmodule
