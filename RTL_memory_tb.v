// File Name: RTL_memory_tb.v
// Author: Matt Healea

// This file is a test bench for a SRAM memory for a simple CISC processor
  
`timescale 1ns / 1ns

module Test_Memory;

reg 	MemEnable, 
		MemReadWrite, 
		clk;
		
reg [255:0]	 	DataIn;				// Bus line in
reg [6:0]		Address;

wire [255:0] 	DataOut;			// Bus line out
wire 			WriteDone;			// signal that a write occured

integer i,j;

memory DUT(DataOut, WriteDone, DataIn, Address, MemEnable, MemReadWrite, clk);

initial // Clock generator
  begin
    clk = 0;
    forever #10 clk = !clk;
  end
 
initial	// Test stimulus
  begin
  // Cycle through the locations and shift AA across each memory location
    MemEnable = 0;
	DataIn = 255'hAA;
	Address = 8'h0;
	MemEnable = 1;
	for (j=1; j<=32;j=j+1)
		begin
			#10 	
				MemReadWrite = 0;
			
			#10 DataIn = DataIn << 8;  // shift aa to the left
				MemReadWrite = 1;
		end    
  end
  
initial
	#1
  begin
	for (i=1; i<=64;i=i+1)
		begin
			#20	if (Address >= 7)
				Address = 0;
				else
				Address = Address + 1;	
		end
  end
endmodule 