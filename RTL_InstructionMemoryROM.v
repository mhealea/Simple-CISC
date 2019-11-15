// File Name: RTL_InstructionMemoryROM.v
// Author: Matt Healea

// This module is a read only memory (ROM) for the instruction set of the simple CISC Processor

`timescale 1ns / 1ns

module InstructionMemoryROM (
InstructionBusOut, 			// Bus line to execution engine
InstructionBusIn,			// Bus line into instruction memory
InstructionAddress,			// current instruction memory address 
InstEnable, 				// instruction memory enable
DidRead,					// outgoing signal that the instrcution has been read 
reset,						// system reset signal
clk							// clock signal
);						

parameter SIZE = 32;			// 32-bit instructions

input wire 	InstEnable, 		// enables instruction memory module
			reset,				// system reset switch
			clk;				// the clock
			
input wire [6:0] 		InstructionAddress;			// instruction memory address
input wire [SIZE-1:0]	InstructionBusIn;			// the input bus line

output reg [SIZE-1:0] 	InstructionBusOut;			// the outoput bus line
output reg 				DidRead;					// signals that a read occured

// internal register
reg		[SIZE-1:0] MemArray[5:0];					// actual 32-bit, 6 location memory block

always @(posedge reset)
	begin
	// resets to instruction address // should be changed to zero in execution engine
		InstructionBusOut = 0;		
		MemArray[0] = 32'b0000_0001_0000_0010_0000_0000_0000_0001;
		MemArray[1] = 32'b0000_0010_0000_0011_0000_0010_0000_0000;
		MemArray[2] = 32'b0000_0100_0000_0100_0000_0011_1111_1111;
		MemArray[3] = 32'b0000_0011_0000_0111_0000_0100_0010_1010;
		MemArray[4] = 32'b0000_0101_0000_0101_0000_0111_0000_0100;
		MemArray[5] = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		InstructionBusOut = MemArray[0];

	end

always @ (negedge clk) 
begin 
	DidRead = 0;
	if (InstEnable)	
		begin
			InstructionBusOut = MemArray[InstructionAddress]; // we read the memory at the specified address
			DidRead = 1;		
		end // end if
end // end always

endmodule