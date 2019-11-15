// File: RTL_ALU_tb.v
// Author: Matt Healea

// This is a Matrix ALU for a simple CISC processor test bench

`timescale 1ns / 1ns

module Test_ALU;

reg		 [255:0] 	MemMatIn;			// input array
reg		 [2:0] 	 	Op_Code;			// determines which math operatoin is to be performed
reg		 [7:0]		SOURCE2;			// scalar number for scaling
reg		 			Load_Matrix1,		// signals to load first internal matrix
					Load_Matrix2,		// signals to load second internal matrix
					reset,				// reset signal
					clk;				// clock signal

wire	 [255:0] 	MemMatOut;			// output array
wire	 			FinishFlag;			// signals that computation is complete
wire	 			Load1,				// signals that internal matrix one is loaded
					Load2;				// signals that internal matrix two is loaded
					
parameter ADD  	= 3'b001;				// Addition op code
parameter SUB  	= 3'b010;				// Subtration op code
parameter SCALE = 3'b011;               // Scale op code
parameter TRANS = 3'b100;               // Transpose op code
parameter MULTI = 3'b101;               // Multiply op code

// Instantiate the ALU
ALU DUT(
FinishFlag,
MemMatOut,
MemMatIn,
Op_Code,
Load_Matrix1,
Load_Matrix2,
Load1, 
Load2,
SOURCE2, 
reset, 
clk
);

initial
	begin
		clk = 0;
		forever #5 clk = !clk;			// clock generator
	end	

initial
	begin
		Load_Matrix1 = 0;				// signal to load the first internal matrix of the ALU
		Load_Matrix2 = 0;				// signal to load the second internal matrix of the ALU
		SOURCE2 = 5;					// The second source houses the scalar for the scale operation
		reset = 0;						
		#1 reset = 1;					// toggle reset
		#1 reset = 0;
		
		Load_Matrix1 = 1;
		MemMatIn[15:0] 		= 16'd5;  // row 0
		MemMatIn[31:16] 	= 16'd8;
		MemMatIn[47:32] 	= 16'd9;
		MemMatIn[63:48] 	= 16'd2;
							     
		MemMatIn[79:64] 	= 16'd7;  // row 1
		MemMatIn[95:80] 	= 16'd3;
		MemMatIn[111:96] 	= 16'd8;
		MemMatIn[127:112]  	= 16'd4;
							     
		MemMatIn[143:128] 	= 16'd6; //  row 2
		MemMatIn[159:144]	= 16'd5;
		MemMatIn[175:160] 	= 16'd4;
		MemMatIn[191:176] 	= 16'd3;
							     
		MemMatIn[207:192] 	= 16'd8; // row 3
		MemMatIn[223:208] 	= 16'd5;
		MemMatIn[239:224] 	= 16'd7;
		MemMatIn[255:240]	= 16'd6;
		
		// debugging // verification
			$display("Matrix 1");
			$display(" %d  %d   %d  %d",MemMatIn[15:0],MemMatIn[31:16],MemMatIn[47:32],MemMatIn[63:48]);
			$display(" %d  %d   %d  %d",MemMatIn[79:64],MemMatIn[95:80],MemMatIn[111:96],MemMatIn[127:112]);
			$display(" %d  %d   %d  %d",MemMatIn[143:128],MemMatIn[159:144],MemMatIn[175:160],MemMatIn[191:176]);
			$display(" %d  %d   %d  %d",MemMatIn[207:192],MemMatIn[223:208],MemMatIn[239:224],MemMatIn[255:240]);
			$display("-----------------------------------");
		
		wait (Load1 == 1)
		Load_Matrix1 = 0;
		Load_Matrix2 = 1;
		MemMatIn[15:0] 		= 16'd11; // row 0
		MemMatIn[31:16] 	= 16'd14;
		MemMatIn[47:32] 	= 16'd19;
		MemMatIn[63:48] 	= 16'd18;
							  
		MemMatIn[79:64] 	= 16'd6;  // row 1
		MemMatIn[95:80] 	= 16'd9;
		MemMatIn[111:96] 	= 16'd3;
		MemMatIn[127:112]  	= 16'd5;
							  
		MemMatIn[143:128] 	= 16'd12; // row 2
		MemMatIn[159:144]	= 16'd10;
		MemMatIn[175:160] 	= 16'd15;
		MemMatIn[191:176] 	= 16'd14;
							  
		MemMatIn[207:192] 	= 16'd1;  // row 3
		MemMatIn[223:208] 	= 16'd3;
		MemMatIn[239:224] 	= 16'd5;
		MemMatIn[255:240]	= 16'd7;
		
		// debugging // verification
			$display("Matrix 2");
			$display(" %d  %d   %d  %d",MemMatIn[15:0],MemMatIn[31:16],MemMatIn[47:32],MemMatIn[63:48]);
			$display(" %d  %d   %d  %d",MemMatIn[79:64],MemMatIn[95:80],MemMatIn[111:96],MemMatIn[127:112]);
			$display(" %d  %d   %d  %d",MemMatIn[143:128],MemMatIn[159:144],MemMatIn[175:160],MemMatIn[191:176]);
			$display(" %d  %d   %d  %d",MemMatIn[207:192],MemMatIn[223:208],MemMatIn[239:224],MemMatIn[255:240]);
			$display("-----------------------------------");
		
		wait (Load2 == 1)
		// Testing individual operations (Change TRANS to other parameters for other operations)
		Op_Code = TRANS;
		#1
		$display("Result Matrix");									
			$display(" %d  %d   %d  %d",MemMatOut[15:0],MemMatOut[31:16],MemMatOut[47:32],MemMatOut[63:48]);
			$display(" %d  %d   %d  %d",MemMatOut[79:64],MemMatOut[95:80],MemMatOut[111:96],MemMatOut[127:112]);
			$display(" %d  %d   %d  %d",MemMatOut[143:128],MemMatOut[159:144],MemMatOut[175:160],MemMatOut[191:176]);
			$display(" %d  %d   %d  %d",MemMatOut[207:192],MemMatOut[223:208],MemMatOut[239:224],MemMatOut[255:240]);
			$display(" FinishFlag =  %b", FinishFlag);
	end

endmodule