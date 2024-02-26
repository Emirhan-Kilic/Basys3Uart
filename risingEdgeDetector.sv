`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 03:44:02 AM
// Design Name: 
// Module Name: risingEdgeDetector
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


module risingEdgeDetector(
  input  logic clk,
  input  logic sig,
  output logic edg
);

  reg sig_dly;

  always @(posedge clk) begin
    sig_dly <= sig;
  end

  assign edg = sig & ~sig_dly;

endmodule