`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 03:51:06 AM
// Design Name: 
// Module Name: sevenSegmentDisplayStage3
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


module sevenSegmentDisplayStage3(
    input logic reset,
    input logic clk,
    input logic BTNU,
    input logic BTNR,
    input logic BTNL,
    input logic [7:0] TXBUF[3:0],
    input logic [7:0] RXBUF[3:0],

    output logic [6:0] sevenSegmentOut,
    output logic [3:0] anodeOpen,

    output logic memoryPage,
    output logic [1:0] currentpage


    );



	logic[31:0]generator = 32'b0;
    logic clk_out;
	
	always @ (posedge clk) begin
	
		generator <= generator + 32'd1;
		if(generator == 32'd100000) begin
		clk_out = ~ clk_out;
		generator<= 32'b0;
		
		end
		
	end
	

    reg regedgeButtonU;
    reg regedgeButtonL;
    reg regedgeButtonR;


    risingEdgeDetector edgDetectedforUp(
        .clk(clk_out),
        .sig(BTNU),
        .edg(regedgeButtonU)
    );

    risingEdgeDetector edgDetectedforLeft(
        .clk(clk_out),
        .sig(BTNL),
        .edg(regedgeButtonL)
    );
    risingEdgeDetector edgDetectedforRight(
        .clk(clk_out),
        .sig(BTNR),
        .edg(regedgeButtonR)
    );



    reg [3:0] dividedValues [3:0];


    reg loadTX32;
    reg loadTX10;
    reg loadRX32;
    reg loadRX10;

    reg [2:0] nStage;
    reg [2:0] pStage;

    reg [3:0] refreshCounter;
    reg refreshCounter_clr;
    reg show;


    always_ff @(posedge clk_out) begin 

        if (reset) pStage <= 2'b00;
        else pStage <= nStage;   

        if (refreshCounter_clr) begin
            refreshCounter <= 0;
        end


        if (loadTX32) begin

            dividedValues[3] <= TXBUF[3][7:4];
            dividedValues[2] <= TXBUF[3][3:0];
            dividedValues[1] <= TXBUF[2][7:4];
            dividedValues[0] <= TXBUF[2][3:0];


        end else if (loadTX10) begin


            dividedValues[3] <= TXBUF[1][7:4];
            dividedValues[2] <= TXBUF[1][3:0];
            dividedValues[1] <= TXBUF[0][7:4];   
            dividedValues[0] <= TXBUF[0][3:0];
            $display("load TX10");

            
        end else if (loadRX32) begin


            dividedValues[3] <= RXBUF[3][7:4];
            dividedValues[2] <= RXBUF[3][3:0];
            dividedValues[1] <= RXBUF[2][7:4];       
            dividedValues[0] <= RXBUF[2][3:0];
            $display("load RX32");            
        end else if (loadRX10) begin


            dividedValues[3] <= RXBUF[1][7:4];
            dividedValues[2] <= RXBUF[1][3:0];
            dividedValues[1] <= RXBUF[0][7:4];       
            dividedValues[0] <= RXBUF[0][3:0];
            $display("load RX10");
        end
            


    if (show) begin
            if ( refreshCounter == 3 ) begin
                refreshCounter <= 0; 
            end
            else begin
                refreshCounter <= refreshCounter + 1;
            $display("The curerent divided value: ", dividedValues[refreshCounter], " result assigned to 7segment: ",sevenSegmentOut, " anode that is open: ", anodeOpen  );

            end

        end
    end



    always @( refreshCounter ) begin

                case(refreshCounter)
                    0: anodeOpen <= 4'b1110; // 14
                    1: anodeOpen <= 4'b1101; // 13
                    2: anodeOpen <= 4'b1011; // 11
                    3: anodeOpen <= 4'b0111; // 7

                endcase

                 case (dividedValues[refreshCounter])

                        4'b0000: sevenSegmentOut <= 7'b0000001; // 0
                        4'b0001: sevenSegmentOut <= 7'b1001111; // 1
                        4'b0010: sevenSegmentOut <= 7'b0010010; // 2
                        4'b0011: sevenSegmentOut <= 7'b0000110; // 3
                        4'b0100: sevenSegmentOut <= 7'b1001100; // 4
                        4'b0101: sevenSegmentOut <= 7'b0100100; // 5
                        4'b0110: sevenSegmentOut <= 7'b0100000; // 6
                        4'b0111: sevenSegmentOut <= 7'b0001111; // 7
                        4'b1000: sevenSegmentOut <= 7'b0000000; // 8
                        4'b1001: sevenSegmentOut <= 7'b0000100; // 9
                        4'b1010: sevenSegmentOut <= 7'b0001000; // A
                        4'b1011: sevenSegmentOut <= 7'b1100000; // B
                        4'b1100: sevenSegmentOut <= 7'b0110001; // C
                        4'b1101: sevenSegmentOut <= 7'b1000010; // D
                        4'b1110: sevenSegmentOut <= 7'b0110000; // E
                        4'b1111: sevenSegmentOut <= 7'b0111000; // F
                    default: sevenSegmentOut = 7'b0000001; // Display nothing for unrecognized input
                endcase 
                
        
    end






    // b000 init
    // b001 showTX-3-2
    // b010 showTX-1-0
    // b011 showRX-3-2
    // b100 showRX-1-0
    always_comb begin

        case (pStage)
            3'b000: begin
                nStage = 3'b001;
            end
            3'b001: begin

                if (regedgeButtonU) nStage = 3'b011;
                else if (regedgeButtonL) nStage = 3'b010;
                else if (regedgeButtonR) nStage = 3'b010;
                else nStage = 3'b001;
            end
            3'b010: begin

                if (regedgeButtonU) nStage = 3'b011;
                else if (regedgeButtonL) nStage = 3'b001;
                else if (regedgeButtonR) nStage = 3'b001;
                else nStage = 3'b010;   
            end
            3'b011: begin
                if (regedgeButtonU) nStage = 3'b001;
                else if (regedgeButtonL) nStage = 3'b100;
                else if (regedgeButtonR) nStage = 3'b100;
                else nStage = 3'b011;         
            end
            3'b100: begin
                if (regedgeButtonU) nStage = 3'b001;
                else if (regedgeButtonL) nStage = 3'b011;
                else if (regedgeButtonR) nStage = 3'b011;
                else nStage = 3'b100;             
            end
            3'b101: nStage = 3'b000;
            3'b110: nStage = 3'b000;
            3'b111: nStage = 3'b000;
            default: nStage = 3'b000;

            
        endcase
    end



    // 000 init
    // 001 showTX-3-2
    // 010 showTX-1-0
    // 011 showRX-3-2
    // 100 showRX-1-0


always_comb begin
        case (pStage)
            3'b000: begin
                $display("**** INIT FOR 7SEGMENT ****");

                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                loadRX10 = 1'b0;
                show = 1'b0;
                refreshCounter_clr = 1'b1;
                memoryPage = 1'b0;
                currentpage = 2'b10;

            end
            3'b001: begin
                $display("**** SHOW TX32 FOR 7SEGMENT ****");

                loadTX32 = 1'b1;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                loadRX10 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b0;
                currentpage = 2'b10;

            end
            3'b010: begin
                $display("**** SHOW TX10 FOR 7SEGMENT ****");

                loadTX10 = 1'b1;
                loadTX32 = 1'b0;
                loadRX32 = 1'b0;
                loadRX10 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b0;
                currentpage = 2'b01;


            end
            3'b011: begin
                $display("**** SHOW RX32 FOR 7SEGMENT ****");

                loadRX32 = 1'b1;
                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX10 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b1;
                currentpage = 2'b10;


            end
            3'b100: begin
                $display("**** SHOW RX10 FOR 7SEGMENT ****");

                loadRX10 = 1'b1;
                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b1;
                currentpage = 2'b01;

            end

            3'b101: begin
                loadRX10 = 1'b0;
                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b1;
                currentpage = 2'b10;

            end
            3'b110: begin
                loadRX10 = 1'b0;
                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b1;
                currentpage = 2'b10;

            end
            3'b111: begin
                loadRX10 = 1'b0;
                loadTX32 = 1'b0;
                loadTX10 = 1'b0;
                loadRX32 = 1'b0;
                show = 1'b1;
                refreshCounter_clr = 1'b0;
                memoryPage = 1'b1;
                currentpage = 2'b10;

            end


        endcase
end


endmodule