// File Name: RTL_Register_tb.v
// Author: Matt Healea

// This file is a test bench for a register to be used in a simple CISC processor
  
`timescale 1ns / 1ns

module Test_Register;

wire [255:0] RegDataOut;		// bus line out of register

reg [255:0] RegDataIn;			// bus line into register

reg Enable,
	ReadWrite,
	reset,
	clk;

// instantiate the register
register1 Reg1(RegDataOut, RegDataIn, Enable, ReadWrite, reset, clk);

initial
	begin
		clk = 0;
		forever #5 clk = !clk;	// clock generator
	end

initial
	begin
	// toggle reset and shift AA across the entire length (bit depth) of the register
		Enable = 1;
		RegDataIn = 0;
		reset = 0;
		#1 reset = 1;
		#1 reset = 0;
		
		#3
		ReadWrite = 0;
		RegDataIn = 32'hAA;
		
		#5
		ReadWrite = 1;
		RegDataIn = RegDataIn << 8;
		
	end

endmodule