`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 02:38:10 AM
// Design Name: 
// Module Name: transmitterStage3
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


module transmitterStage3(

    input logic reset,
    input logic clk,
    input logic [7:0] inputData,
    input logic dataLoad,
    input logic dataTransmit,
    input logic stage4,
    output logic [7:0] outLight,
    output logic TX,
    output logic [7:0] TXBUF[3:0]


    );

    reg redgeDataLoad;
    reg redgeTransmitData;

    risingEdgeDetector edgDetectedforLoad(
        .clk(clk),
        .sig(dataLoad),
        .edg(redgeDataLoad)
    );

        risingEdgeDetector edgDetectedforTransmit(
        .clk(clk),
        .sig(dataTransmit),
        .edg(redgeTransmitData)
    );


    reg [1:0] nStage;
    reg [1:0] pStage;

    reg txbuf_load;
    reg txbuf_clr;
    reg counter_clr;
    reg send_sgnl;
    reg countbit_mt_9;
    reg countbitCompare9_clr;

    reg [5:0] countBits;
    reg [9:0] sendingReg;

    reg sendingReg_clr;


    reg [16:0] baudRateReg;
    reg baudratePerOut;
    reg baudRateReg_clr;


    reg [55:0] allSendReg;


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



        if (sendingReg_clr) begin
            sendingReg <= 0;
        end

        if (countbitCompare9_clr) begin

            countbit_mt_9 <= 1'b0;

        end

        if (txbuf_clr) begin
            TXBUF[0] <= 8'b00000000;
            TXBUF[1] <= 8'b00000000;
            TXBUF[2] <= 8'b00000000;
            TXBUF[3] <= 8'b00000000;
        end
        if (txbuf_load) begin 
            TXBUF[3] <= TXBUF[2];
            TXBUF[2] <= TXBUF[1];
            TXBUF[1] <= TXBUF[0];
            TXBUF[0] <= inputData;


        end

        if (!send_sgnl) begin
            TX <= 1'b1;
            sendingReg <= {1'b1, TXBUF[3], 1'b0};
            allSendReg <= {1'b1, TXBUF[3], 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, TXBUF[2], 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, TXBUF[1], 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, TXBUF[0], 1'b0 };

        end 
        else if (send_sgnl) begin
            if(stage4) begin

                if (countBits > 54 ) countbit_mt_9 <= 1'b1; 
                else begin
                    countbit_mt_9 <= 1'b0;
                    TX <= allSendReg[0];

                    if (baudratePerOut) begin
                        countBits <= countBits + 1;
                        allSendReg <= allSendReg >> 1;
                        baudRateReg <= 0;
                    end
                end


                
            end 
            else if (!stage4) begin
                if (countBits > 9 ) countbit_mt_9 <= 1'b1; 
                else begin
                    countbit_mt_9 <= 1'b0;
                    TX <= sendingReg[0];

                    if (baudratePerOut) begin
                        countBits <= countBits + 1;
                        sendingReg <= sendingReg >> 1;
                        baudRateReg <= 0;
                    end


                end
                
            end


        end

        if (counter_clr) begin
            countBits <= 0;
        end 
    end


    always @(TXBUF[0]) begin
        outLight <= TXBUF[0];
    end 

    // 00 init
    // 01 wait
    // 10 load
    // 11 send
    always_comb begin

        case (pStage)
            2'b00: begin
                nStage = 2'b01;
            end
            2'b01: begin
                $display("TXBUF: ", TXBUF[0], " ", TXBUF[1], " ", TXBUF[2], " ", TXBUF[3]);
                if (redgeDataLoad) nStage = 2'b10;
                else if (redgeTransmitData) nStage = 2'b11;
                else nStage = 2'b01; 

            end
            2'b10: begin
                nStage = 2'b01;

            end
            2'b11: begin
                if (countbit_mt_9) nStage = 2'b01;
                else nStage = 2'b11;

            end
            default: nStage = 2'b00;
            
        endcase
    end


    // 00 init
    // 01 wait
    // 10 load
    // 11 send

always_comb begin
        case (pStage)
            2'b00: begin
                txbuf_clr = 1'b1;                                
                txbuf_load = 1'b0;
                send_sgnl = 1'b0;
                counter_clr = 1'b1;
                countbitCompare9_clr = 1'b1;
                sendingReg_clr = 1'b1; 
                baudRateReg_clr = 1'b1;
                                          
            end
            2'b01: begin

                txbuf_clr = 1'b0;
                txbuf_load = 1'b0;                                
                send_sgnl = 1'b0;                                
                counter_clr = 1'b1;                                
                countbitCompare9_clr = 1'b1;
                sendingReg_clr = 1'b0; 
                baudRateReg_clr = 1'b1;

            end
            2'b10: begin

                txbuf_clr = 1'b0;   
                txbuf_load = 1'b1;                                                
                send_sgnl = 1'b0;                                
                counter_clr = 1'b1;                                
                countbitCompare9_clr = 1'b1;
                sendingReg_clr = 1'b0; 
                baudRateReg_clr = 1'b1;


            end
            2'b11: begin
                
                txbuf_clr = 1'b0;
                txbuf_load = 1'b0;                                
                send_sgnl = 1'b1;                                
                counter_clr = 1'b0;                                
                countbitCompare9_clr = 1'b0;
                sendingReg_clr = 1'b0; 
                baudRateReg_clr = 1'b0;

            end

        endcase
end


endmodule
