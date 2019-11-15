// File Name: RTL_Register.v
// Author: Matt Healea

// ReadWrite bit selects whether we read or write to memory
// ReadWrite is high means that we read at falling edge of clock, low means write at rising edge of clock


`timescale 1ns / 1ns

module register1 (RegDataOut, RegDataIn, Enable, ReadWrite, reset, clk);

input wire 	Enable, ReadWrite,reset, clk;
input wire	[255:0] RegDataIn;
output reg	[255:0] RegDataOut;

always @ (reset == 1)
	begin
		RegDataOut = 0;
	end

reg		[255:0] MemArray;

always @ (negedge clk)  

	if (Enable)	
		begin
			if(ReadWrite)
				begin
					RegDataOut = MemArray;  	// if ReadWrite is high we read at negitive edge of clock
				end
		end
		
always @ (posedge clk)

	if (Enable)	
		begin
			if(!ReadWrite)
				begin
					MemArray = RegDataIn;   	// if ReadWrite is low we write at positive edge of clock
				end								
		end                                     	

endmodule