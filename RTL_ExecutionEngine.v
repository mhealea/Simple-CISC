// File Name: RTL_ExecutionEngine2.v
// Author: Matt Healea

// This module is an execution engine to be used in a simple CISC processor. 

`timescale 1ns / 1ns

/*
											Instruction Breakdown
parameter instruction = operation (8 bits)	Destination (8 bits)	Source1 (8 bits)		Source2 (8 bits)

example:  	adder =  000_0001	(op code)	0000_0010	(memory cell M2)	0000_0000 (memory cell M0)	00000001 (memory cell M1)

			
			
									********Op Codes********
			
Operation						Destination							Source1						Source2
reset_stop: 0000_0000			M2:			0000_0010				M0:		0000_0000			M0:		0000_0000
adder:		0000_0001			M3:			0000_0011				M1:		0000_0001			M1:		0000_0001
subtract:	0000_0010			M4:			0000_0100				M2:		0000_0010			M2:		0000_0010
scalar:		0000_0011			M5:			0000_0101				M3:		0000_0011			M3:		0000_0011
transpose:	0000_0100			M6:			0000_0110				M4:		0000_0100			M4:		0000_0100	
multiply:	0000_0101			Reg & M6:	0000_0111				M5:		0000_0101			M5:		0000_0101
																	M6:		0000_0110			M6:		0000_0110
																	Reg:	0000_0111			Reg:	0000_0111
																								Scalar:	0010_1010  // 42
															
									***** instrcution sets *****
	
instruciton 1 : 0000_0001_0000_0010_0000_0000_0000_0001 		add, store in M2, SRC1 = M0, SRC2 = M1
instruciton 2 : 0000_0010_0000_0011_0000_0010_0000_0000 		subtract, store in M3, SRC1 = M2, SRC2 = M0	
instruciton 3 : 0000_0100_0000_0100_0000_0011_1111_1111 		transpose, store in M4, SRC1 = M3	
instruciton 4 : 0000_0011_0000_0111_0000_0100_0010_1010 		scale, store in Reg & M6, SRC1 = M4			
instruciton 5 : 0000_0101_0000_0101_0000_0111_0000_0100 		multiply, store in M5, SRC1 = Reg, SRC2 = M4
instruciton 6 : 1111_1111_1111_1111_1111_1111_1111_1111 		STOP   
*/

module ExecutionEngine (
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

// parameter list
parameter SIZE 	= 32;				// bit depth size of instructions
parameter ADD  	= 8'b0000_0001;		// op codes
parameter SUB  	= 8'b0000_0010;
parameter SCALE = 8'b0000_0011;
parameter TRANS = 8'b0000_0100;
parameter MULTI = 8'b0000_0101;
parameter STOP	= 8'b1111_1111;

// State parameters
parameter READ_INST			= 3'b001;
parameter DECODE_INST		= 3'b010;
parameter READ_SOURCE1		= 3'b011;
parameter READ_SOURCE2		= 3'b100;
parameter LOAD1				= 3'b101;
parameter LOAD2				= 3'b110;
parameter MEMORY_WRITE		= 3'b111;

// Ports for General controls
input wire clk;
input wire reset;


// Ports for instruction memory
output reg 	InstEnable; 						// enables instruction memory module
			
output reg [6:0] 		InstructionAddress;
output reg [SIZE-1:0]	InstructionBusIn;

input wire [SIZE-1:0] 	InstructionBusOut;
input wire 				DidRead;				// signals that instruction was read

// Ports for Memory
output reg MemEnable;
output reg MemReadWrite;
output reg [7:0] Address;
output reg [255:0] DataIn;

input wire [255:0]DataOut;

// ports for register
output reg [255:0]RegDataIn;
output reg Enable;
output reg ReadWrite;

// Ports for ALU
output reg Load_Matrix1;
output reg Load_Matrix2;
output reg [7:0] Op_Code;
output reg [7:0] SOURCE2;			// second source for math operation, also the scalar
output reg [255:0] MemMatIn;

input wire [255:0] MemMatOut;
input wire FinishFlag;


// Non-Ported items (internal registers)
reg [7:0] OP_CODE;					// Math operation to be performed
reg [7:0] DESTINATION;				// where the result is stored
reg [7:0] SOURCE1;					// first source for math operation

reg [2:0] State;					// current state for state machine
reg [2:0] Next_State;				// next state for state machine

reg [31:0]  instruction; 			// 32-bit instructions
reg [255:0] InternalMatrix1;		// internal to execution engine, used to port data places	
reg [255:0] InternalMatrix2;		// internal to execution engine, used to port data places
reg [255:0] InternalMatrix3;		// used for result coming out of ALU


always @(reset == 1)
	begin
		// initial settings for execution engine
		State = READ_INST;
		Next_State = 0;
		Op_Code 			= 0;								// Avoiding Xs	
		InternalMatrix1 	= 0;								// Avoiding Xs	
		InternalMatrix2 	= 0;								// Avoiding Xs	
		InternalMatrix3 	= 0;								// Avoiding Xs
		DataIn 				= 0;								// Avoiding Xs
		
	
		// initial settings for Instruction Memory
		instruction 		= InstructionBusOut[SIZE-1:0];		// read the first instruciton from instruction memory
		InstructionAddress 	= 0;								// Address to first location
		InstEnable 			= 1;								// always enabled
	
		// initial settings for Main Memory
		MemEnable 			= 1;								// enables memory
		MemReadWrite		= 1;								// initial read at negedge clock
		Address				= 0;								// read first matrix into execution engine
		
		// Initial setting for ALU
		Load_Matrix1	= 0;									// Signals to the ALU begin loading the first matrix
		Load_Matrix2	= 0;									// Signals to the ALU begin loading the second matrix
		
	
		// Initial settings for register
		Enable 				= 1;
		ReadWrite 			= 0;								// If ReadWrite is high we read, low we write
		RegDataIn 			= 0;								// Avoiding Xs
		
	end // end always


// state machine 
always @ (posedge clk)
	begin
		case (State)
			READ_INST: 	
				begin	
					// sets the incoming instrcution to the bus line from instruction memory
					instruction = InstructionBusOut;
					Next_State 	= DECODE_INST;				   
				end
			DECODE_INST:
				begin
					// decodes the incoming instruction
					OP_CODE			= instruction[31:24];
					DESTINATION 	= instruction[23:16];
					SOURCE1 		= instruction[15:8];
					SOURCE2 		= instruction[7:0];
					
					// Setting up math operation
					Op_Code = OP_CODE;			// the left side is an internal reg that gets passed to the ALU
					
					if (Op_Code == 8'b1111_1111)
						begin
							$display($time);
							$stop;
						end
						
					// Setting up read for source one
					Address 		= SOURCE1;
										
					Next_State 		= READ_SOURCE1;					
				end
			READ_SOURCE1:
				begin
					// setting internal matrix 1 to memory's output line
					InternalMatrix1 = DataOut;
					MemMatIn		= InternalMatrix1;
					
					Load_Matrix1 	= 1;
					// setting up source two from memory
					if (Op_Code == SCALE)
						begin
							Address = Address;
						end
					else
						Address 		= SOURCE2;
					
					Next_State 		= READ_SOURCE2;	
				end
			READ_SOURCE2:
				begin
					Load_Matrix1 	= 0;
					// Setting internal matrix 2 to memory's output line
					InternalMatrix2 = DataOut;
					MemMatIn		= InternalMatrix2;
					
					// Set up to load the first matrix to the ALU

					Next_State 		= LOAD1;
					
				end
			LOAD1:
				begin	
					// Matrix 1 is loaded, now we setup matrix two
					if (OP_CODE != SCALE)
						begin
							Load_Matrix2	= 1;
						end
					MemReadWrite	= 0;
										
					Next_State 		= LOAD2;
				end
			LOAD2:
				begin
					// Matrix 2 is now loaded, now we need to perform the math
					Load_Matrix2	= 0;
					
					// setting up the result matrix to come out of the ALU
					InternalMatrix3 = MemMatOut;
					
					// Setting up result matrix to be written to memory
					if (DESTINATION == 8'b0000_0111)
						begin
						// If we specify the register as the destination
							RegDataIn 	= InternalMatrix3;
							Address 	= DESTINATION;
							DataIn		= InternalMatrix3;
						end
					else
						begin
							Address 		= DESTINATION;
							DataIn			= InternalMatrix3;
						end
						
					Next_State 		= MEMORY_WRITE;
				end
			MEMORY_WRITE:
				begin
					// The write will happen at the positive edge of the clock
					
					// Setting up read for the next instruction
					MemReadWrite 	= 1;
					
					// Updating the instruction address for next instruciton
					InstructionAddress = InstructionAddress + 1;
					
					Next_State 		= READ_INST;
				end
			
		endcase
	State = Next_State;

	end // end always

endmodule