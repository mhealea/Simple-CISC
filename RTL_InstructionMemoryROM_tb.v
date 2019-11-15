// File Name: RTL_InstructionMemoryROM_tb.v
// Author: Matt Healea

// This file is a test bench for a ROM for a simple CISC propsessor design

`timescale 1ns / 1ns

module RTL_InstructionMemoryROM_tb;

reg 		InstEnable,
			reset,
			ReadWrite,
			clk;
			
reg [6:0] 	InstructionAddress;
reg [31:0]	InstructionBusIn;

wire [31:0] 	InstructionBusOut;
wire 			DidRead;

// instantiation
InstructionMemory  DUT(
InstructionBusOut, 			// Bus line to execution engine
InstructionBusIn,			// Bus line into instruction memory
InstructionAddress,			// current instruction memory address 
InstEnable, 				// instruction memory enable
DidRead,					// outgoing signal that the instrcution has been read 
reset,						// system reset signal
clk							// clock signal
);	

initial
	begin
		clk = 0;
		forever #5 clk = !clk;			// clock generator
	end	
	
initial
	begin
	// Set the initial address to the first location, assure there aren't garbage values, enable the ROM, toggle reset and increment the instruction.
		InstructionAddress = 0;
		InstructionBusIn = 0;
		InstEnable = 1;
		reset = 1;
		#1 
		reset = 0;
			InstructionAddress = 0;
			
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
		#10 InstructionAddress = InstructionAddress +1;
		
	end
endmodule	