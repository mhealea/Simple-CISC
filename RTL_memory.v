// File Name: RTL_memory.v
// Author: Matt Healea

// ReadWrite bit selects whether we read or write to memory
// ReadWrite is high means that we read at rising edge of clock, low means write at rising edge of clock


`timescale 1ns / 1ns

module memory (DataOut, WriteDone, DataIn, Address, MemEnable, MemReadWrite, reset, clk);

input	MemEnable, 
		MemReadWrite, 
		clk;
		
input wire	[255:0] 	DataIn; 	// Bus line into the memory
input wire	[7:0] 		Address;	// The 8 different addresses of memory
input wire				reset;		// Universial reset signal

output reg	[255:0] DataOut;		// Bus line out of memory
output reg 			WriteDone;		// signal that goes high when a write has happened

reg		[255:0] MemArray[7:0];		// The actual memory block itself, 8 different locations (for each address) and each of them are 256 bit

always @ (posedge reset)
	begin
		MemArray[0] = 256'h_0003_0010_000f_0002_000d_0008_0002_0009_0009_000b_0006_0007_0022_0004_000c_0004; // Preloaded the first two matricies into memory
		MemArray[1] = 256'h_0009_0007_0005_0003_000c_000d_0038_0012_0001_0004_0006_0007_0016_0043_002d_0017;
	end

always @ (negedge clk)  

	if (MemEnable)	
		begin
			if(MemReadWrite) 
				begin
					DataOut = MemArray[Address]; // if ReadWrite is high we read at negitive edge of clock (read at negative, write at positive so we know that the data is there)
					WriteDone = 1;	// signal goes high (tells me that the read happened)
				end
		end
	else
		begin
			WriteDone = 0; // otherwise it didn't happen
		end
		
always @ (posedge clk)

	if (MemEnable)	
		begin
			if(!MemReadWrite) 
				begin
					MemArray[Address] = DataIn;    	// if ReadWrite is low we write at positive edge of clock
					WriteDone = 1;					// This is to avoid ReadWrite issues with timing
				end
		end                                              

endmodule