`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 02:38:49 AM
// Design Name: 
// Module Name: mainModuleStage3
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


module mainModuleStage3(

    input logic reset,
    input logic clk,
    input logic [7:0] inputData,

    input logic dataLoad,
    input logic dataTransmit,

    input logic btnU,
    input logic btnR,
    input logic btnL,

    input logic stage4,


    output logic [6:0] sevenSegmentOut,
    output logic [3:0] anodeOpen,
    output logic [7:0] outLight,

    output logic memoryPage,
    output logic [1:0] currentpage,

    output logic TX,
    input logic RX

    );



    logic [7:0] TXBUF[3:0];
    logic [7:0] RXBUF [3:0];

    transmitterStage3 transmitter (
        .reset(reset),
        .clk(clk),
        .inputData(inputData),
        .dataLoad(dataLoad),
        .dataTransmit(dataTransmit),
        .outLight(outLight),
        .TX(TX),
        .TXBUF(TXBUF),
        .stage4(stage4)

    );

    recieverStage3 reciever(
        .reset(reset),
        .clk(clk),
        .RX(RX),
        .RXBUF(RXBUF)

    );

    sevenSegmentDisplayStage3 display(
        .reset(reset),
        .clk(clk),
        .BTNU(btnU),
        .BTNR(btnR),
        .BTNL(btnL),
        .TXBUF(TXBUF),
        .RXBUF(RXBUF),
        .sevenSegmentOut(sevenSegmentOut),
        .anodeOpen(anodeOpen),
        .memoryPage(memoryPage),
        .currentpage(currentpage)

    );






endmodule