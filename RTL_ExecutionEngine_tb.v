// File Name: RTL_ExecutionEngine_tb.v
// Author: Matt Healea

// This module is an execution engine test bench to be used in a simple CISC processor. 
`timescale 1ns / 1ns

module RTL_ExecutionEngine_tb2;
// general control signals
reg reset;
reg clk;

// signals for instruction memory 
wire InstEnable 				;
wire [6:0] InstructionAddress   ;
wire [31:0]InstructionBusIn     ;
wire [31:0]InstructionBusOut    ;
wire DidRead                	;

// signals for memory
wire MemReadWrite		;
wire MemEnable          ;
wire [255:0] DataIn     ;
wire [255:0] DataOut    ;
wire [7:0] Address      ;

// signals for register
wire Enable				;
wire ReadWrite  		;
wire [255:0] RegDataIn  ;
wire [255:0] RegDataOut ;

// signals for ALU
wire Load_Matrix1			;
wire Load_Matrix2   		;
wire [255:0] MemMatIn       ;
wire [255:0] MemMatOut      ;
wire [7:0] Op_Code        	;
wire FinishFlag     		;
wire [7:0] SOURCE2			;

wire [255:0] InternalMatrix1;
wire [255:0] InternalMatrix2;

// instantiate the modules
InstructionMemoryROM InstMem(
InstructionBusOut, 			// Bus line to execution engine
InstructionBusIn,			// Bus line into instruction memory
InstructionAddress,			// current instruction memory address 
InstEnable, 				// instruction memory enable
DidRead,					// outgoing signal that the instrcution has been read 
reset,						// system reset signal
clk							// clock signal
);			
memory RTLMemory(DataOut, WriteDone, DataIn, Address, MemEnable, MemReadWrite, reset, clk);
register1 register(RegDataOut, RegDataIn, Enable, ReadWrite, reset, clk);

ALU alu(
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

// instantiate the execution engine
ExecutionEngine DUT(
// General Control signals
clk,
reset, 

// ports for instruction memory 
InstEnable, 			
InstructionAddress,
InstructionBusIn,
InstructionBusOut,
DidRead,

// ports for memory
MemReadWrite,
MemEnable,
DataIn,
DataOut,
Address,

// ports for register
Enable,
ReadWrite,
RegDataIn,

// ports for ALU
Load_Matrix1,
Load_Matrix2,
MemMatIn,
MemMatOut,
Op_Code,
SOURCE2,
FinishFlag
);


always // Clock generator
  begin
    clk = 0;
    forever #5 clk = !clk;
  end

initial
	begin
		reset = 0;			// toggle reset
		#1
		reset = 1;
		#1
		reset = 0;
		
		#24
		$display("Matrix 1 Matrix");									
		$display(" %d  %d   %d  %d",MemMatIn[15:0],		MemMatIn[31:16],	MemMatIn[47:32],	MemMatIn[63:48]);
		$display(" %d  %d   %d  %d",MemMatIn[79:64],	MemMatIn[95:80],	MemMatIn[111:96],	MemMatIn[127:112]);
		$display(" %d  %d   %d  %d",MemMatIn[143:128],	MemMatIn[159:144],	MemMatIn[175:160],	MemMatIn[191:176]);
		$display(" %d  %d   %d  %d",MemMatIn[207:192],	MemMatIn[223:208],	MemMatIn[239:224],	MemMatIn[255:240]);
		$display("system time", $time);
		
		#10
		$display("Matrix 2 Matrix");									
		$display(" %d  %d   %d  %d",MemMatIn[15:0],		MemMatIn[31:16],	MemMatIn[47:32],	MemMatIn[63:48]);
		$display(" %d  %d   %d  %d",MemMatIn[79:64],	MemMatIn[95:80],	MemMatIn[111:96],	MemMatIn[127:112]);
		$display(" %d  %d   %d  %d",MemMatIn[143:128],	MemMatIn[159:144],	MemMatIn[175:160],	MemMatIn[191:176]);
		$display(" %d  %d   %d  %d",MemMatIn[207:192],	MemMatIn[223:208],	MemMatIn[239:224],	MemMatIn[255:240]);
		$display("system time", $time);
		
		#10
		$display("Addition Result");									
		$display(" %d  %d   %d  %d",MemMatOut[15:0],	MemMatOut[31:16],	MemMatOut[47:32],	MemMatOut[63:48]);
		$display(" %d  %d   %d  %d",MemMatOut[79:64],	MemMatOut[95:80],	MemMatOut[111:96],	MemMatOut[127:112]);
		$display(" %d  %d   %d  %d",MemMatOut[143:128],	MemMatOut[159:144],	MemMatOut[175:160],	MemMatOut[191:176]);
		$display(" %d  %d   %d  %d",MemMatOut[207:192],	MemMatOut[223:208],	MemMatOut[239:224],	MemMatOut[255:240]);		
		$display("system time", $time);
		
		#70
		$display("Subtraction Result");									
		$display(" %d  %d   %d  %d",MemMatOut[15:0],	MemMatOut[31:16],	MemMatOut[47:32],	MemMatOut[63:48]);
		$display(" %d  %d   %d  %d",MemMatOut[79:64],	MemMatOut[95:80],	MemMatOut[111:96],	MemMatOut[127:112]);
		$display(" %d  %d   %d  %d",MemMatOut[143:128],	MemMatOut[159:144],	MemMatOut[175:160],	MemMatOut[191:176]);
		$display(" %d  %d   %d  %d",MemMatOut[207:192],	MemMatOut[223:208],	MemMatOut[239:224],	MemMatOut[255:240]);
		$display("system time", $time);
		
		#50
		$display("Transpose Result");									
		$display(" %d  %d   %d  %d",MemMatOut[15:0],	MemMatOut[31:16],	MemMatOut[47:32],	MemMatOut[63:48]);
		$display(" %d  %d   %d  %d",MemMatOut[79:64],	MemMatOut[95:80],	MemMatOut[111:96],	MemMatOut[127:112]);
		$display(" %d  %d   %d  %d",MemMatOut[143:128],	MemMatOut[159:144],	MemMatOut[175:160],	MemMatOut[191:176]);
		$display(" %d  %d   %d  %d",MemMatOut[207:192],	MemMatOut[223:208],	MemMatOut[239:224],	MemMatOut[255:240]);
		$display("system time", $time);
		
		#70
		$display("Scaled Result");									
		$display(" %d  %d   %d  %d",MemMatOut[15:0],	MemMatOut[31:16],	MemMatOut[47:32],	MemMatOut[63:48]);
		$display(" %d  %d   %d  %d",MemMatOut[79:64],	MemMatOut[95:80],	MemMatOut[111:96],	MemMatOut[127:112]);
		$display(" %d  %d   %d  %d",MemMatOut[143:128],	MemMatOut[159:144],	MemMatOut[175:160],	MemMatOut[191:176]);
		$display(" %d  %d   %d  %d",MemMatOut[207:192],	MemMatOut[223:208],	MemMatOut[239:224],	MemMatOut[255:240]);
		$display("system time", $time);
		
		#65
		$display("Matrix 1 Matrix");									
		$display(" %d  %d   %d  %d",MemMatIn[15:0],		MemMatIn[31:16],	MemMatIn[47:32],	MemMatIn[63:48]);
		$display(" %d  %d   %d  %d",MemMatIn[79:64],	MemMatIn[95:80],	MemMatIn[111:96],	MemMatIn[127:112]);
		$display(" %d  %d   %d  %d",MemMatIn[143:128],	MemMatIn[159:144],	MemMatIn[175:160],	MemMatIn[191:176]);
		$display(" %d  %d   %d  %d",MemMatIn[207:192],	MemMatIn[223:208],	MemMatIn[239:224],	MemMatIn[255:240]);
		$display("system time", $time);
		
		#5
		$display("Matrix 2 Matrix");									
		$display(" %d  %d   %d  %d",MemMatIn[15:0],		MemMatIn[31:16],	MemMatIn[47:32],	MemMatIn[63:48]);
		$display(" %d  %d   %d  %d",MemMatIn[79:64],	MemMatIn[95:80],	MemMatIn[111:96],	MemMatIn[127:112]);
		$display(" %d  %d   %d  %d",MemMatIn[143:128],	MemMatIn[159:144],	MemMatIn[175:160],	MemMatIn[191:176]);
		$display(" %d  %d   %d  %d",MemMatIn[207:192],	MemMatIn[223:208],	MemMatIn[239:224],	MemMatIn[255:240]);
		$display("system time", $time);
		
		$display("---------------------------------------------");
		
		#20
		
		$display("Multiplied Result");									
		$display(" %d  %d   %d  %d",MemMatOut[15:0],	MemMatOut[31:16],	MemMatOut[47:32],	MemMatOut[63:48]);
		$display(" %d  %d   %d  %d",MemMatOut[79:64],	MemMatOut[95:80],	MemMatOut[111:96],	MemMatOut[127:112]);
		$display(" %d  %d   %d  %d",MemMatOut[143:128],	MemMatOut[159:144],	MemMatOut[175:160],	MemMatOut[191:176]);
		$display(" %d  %d   %d  %d",MemMatOut[207:192],	MemMatOut[223:208],	MemMatOut[239:224],	MemMatOut[255:240]);
		$display("system time", $time);
		
	end

endmodule