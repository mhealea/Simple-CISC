// File: RTL_ALU.v
// Author: Matt Healea

// This is a Matrix ALU for a CISC processor

`timescale 1ns / 1ns

module ALU(
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

input wire [255:0] 	MemMatIn;			// input array
input wire [7:0] 	Op_Code;			// determines which math operatoin is to be performed
input wire [7:0]	SOURCE2;			// scalar number for scaling
input wire 			Load_Matrix1,		// signals to load first internal matrix
					Load_Matrix2,		// signals to load second internal matrix
					reset,				// system reset
					clk;				// clock signal
			
			

output reg [255:0] 	MemMatOut;			// output array (result of operation)
output reg 			FinishFlag;			// signals that computation is complete
output reg 			Load1,				// signals that internal matrix one is loaded
					Load2;				// signals that internal matrix two is loaded
		
// Internal Items		
reg [15:0] IM1[3:0][3:0];				// first 4x4x16 matrix
reg [15:0] IM2[3:0][3:0];				// second 4x4x16 matrix
reg [15:0] ID [3:0][3:0];				// Identity matrix used for scaling
reg [15:0] RM [3:0][3:0];				// 4x4x16 resultant matrix 
					
reg	ID_Done,							// signals identity matrix is loaded
	Math_Done;							// Signals that case level math is complete, used for preparing ouput array
		
parameter ADD  	= 3'b001;
parameter SUB  	= 3'b010;
parameter SCALE = 3'b011;
parameter TRANS = 3'b100;
parameter MULTI = 3'b101;

// setting initial values to avoid garbage output
always @ (posedge reset)
	begin
		Load1 			= 0;
		Load2 			= 0;
		Math_Done 		= 0;
		FinishFlag		= 0;
		MemMatOut		= 0;
	end
always @ (negedge clk)
	if (FinishFlag)
		begin
			Load1 		= 0;
			Load2 		= 0;
			Math_Done 	= 0;
		end

// Loading internal matricies to perform math 
always @ (posedge Load_Matrix1 or posedge Load_Matrix2)
	begin
		FinishFlag = 0;
		if (Load_Matrix1 == 1)
			begin
				//	R  C     16 bits occupied
				IM1[0][0] = MemMatIn[15:0]    ;  //  row 0
				IM1[0][1] = MemMatIn[31:16]   ;
				IM1[0][2] = MemMatIn[47:32]   ;
				IM1[0][3] = MemMatIn[63:48]   ;
				
				IM1[1][0] = MemMatIn[79:64]   ;  // row 1
				IM1[1][1] = MemMatIn[95:80]   ;
				IM1[1][2] = MemMatIn[111:96]  ;
				IM1[1][3] = MemMatIn[127:112] ;
				
				IM1[2][0] = MemMatIn[143:128] ;  // row 2
				IM1[2][1] = MemMatIn[159:144] ;
				IM1[2][2] = MemMatIn[175:160] ;
				IM1[2][3] = MemMatIn[191:176] ;
				
				IM1[3][0] = MemMatIn[207:192] ;  // row 3
				IM1[3][1] = MemMatIn[223:208] ;
				IM1[3][2] = MemMatIn[239:224] ;
				IM1[3][3] = MemMatIn[255:240] ;
				
				if (Op_Code == 3'b011 || Op_Code == 3'b100)
					begin
						Load1 = 1;
						Load2 = 1;
					end
				else
					begin
						Load1 = 1;
					end
			end // end if load 1
		else if (Load_Matrix2 == 1)
			begin
				//	R  C     16 bits occupied
				IM2[0][0] = MemMatIn[15:0]    ;  // row 0
				IM2[0][1] = MemMatIn[31:16]   ;
				IM2[0][2] = MemMatIn[47:32]   ;
				IM2[0][3] = MemMatIn[63:48]   ;
				
				IM2[1][0] = MemMatIn[79:64]   ;  // row 1
				IM2[1][1] = MemMatIn[95:80]   ;
				IM2[1][2] = MemMatIn[111:96]  ;
				IM2[1][3] = MemMatIn[127:112] ;
				
				IM2[2][0] = MemMatIn[143:128] ; // row 2
				IM2[2][1] = MemMatIn[159:144] ;
				IM2[2][2] = MemMatIn[175:160] ;
				IM2[2][3] = MemMatIn[191:176] ;
				
				IM2[3][0] = MemMatIn[207:192] ;  // row 3
				IM2[3][1] = MemMatIn[223:208] ;
				IM2[3][2] = MemMatIn[239:224] ;
				IM2[3][3] = MemMatIn[255:240] ;
				Load2 = 1;
			end // end else
	end // end always		

// Performing math depending on if the internal matricies are loaded
always @ (Load1 == 1 && Load2 == 1 && Op_Code)
	begin
		case (Op_Code)
			ADD: 	
				begin	
					RM[0][0] = IM1[0][0] + IM2[0][0];
					RM[0][1] = IM1[0][1] + IM2[0][1];
					RM[0][2] = IM1[0][2] + IM2[0][2];
					RM[0][3] = IM1[0][3] + IM2[0][3];
					
					RM[1][0] = IM1[1][0] + IM2[1][0];
					RM[1][1] = IM1[1][1] + IM2[1][1];
					RM[1][2] = IM1[1][2] + IM2[1][2];
					RM[1][3] = IM1[1][3] + IM2[1][3];
					
					RM[2][0] = IM1[2][0] + IM2[2][0];
					RM[2][1] = IM1[2][1] + IM2[2][1];
					RM[2][2] = IM1[2][2] + IM2[2][2];
					RM[2][3] = IM1[2][3] + IM2[2][3];
					
					RM[3][0] = IM1[3][0] + IM2[3][0];
					RM[3][1] = IM1[3][1] + IM2[3][1];
					RM[3][2] = IM1[3][2] + IM2[3][2];
					RM[3][3] = IM1[3][3] + IM2[3][3];
					Math_Done = 1;
				end
			SUB:
				begin	
					RM[0][0] = IM1[0][0] - IM2[0][0];
					RM[0][1] = IM1[0][1] - IM2[0][1];
					RM[0][2] = IM1[0][2] - IM2[0][2];
					RM[0][3] = IM1[0][3] - IM2[0][3];
					                     
					RM[1][0] = IM1[1][0] - IM2[1][0];
					RM[1][1] = IM1[1][1] - IM2[1][1];
					RM[1][2] = IM1[1][2] - IM2[1][2];
					RM[1][3] = IM1[1][3] - IM2[1][3];
					                     
					RM[2][0] = IM1[2][0] - IM2[2][0];
					RM[2][1] = IM1[2][1] - IM2[2][1];
					RM[2][2] = IM1[2][2] - IM2[2][2];
					RM[2][3] = IM1[2][3] - IM2[2][3];
					                     
					RM[3][0] = IM1[3][0] - IM2[3][0];
					RM[3][1] = IM1[3][1] - IM2[3][1];
					RM[3][2] = IM1[3][2] - IM2[3][2];
					RM[3][3] = IM1[3][3] - IM2[3][3];
					Math_Done = 1;
				end
			SCALE:
				begin
					// creating identity matrix
					ID[0][0] = SOURCE2;	// Row 0
					ID[0][1] = 16'b0;
					ID[0][2] = 16'b0;
					ID[0][3] = 16'b0;
					
					ID[1][0] = 16'b0;	// Row 1
					ID[1][1] = SOURCE2;
					ID[1][2] = 16'b0;
					ID[1][3] = 16'b0;
					
					ID[2][0] = 16'b0;	// Row 2
					ID[2][1] = 16'b0;
					ID[2][2] = SOURCE2;
					ID[2][3] = 16'b0;
					
					ID[3][0] = 16'b0;	// Row 3
					ID[3][1] = 16'b0;
					ID[3][2] = 16'b0;
					ID[3][3] = SOURCE2;
					ID_Done = 1; // flagging that ID matrix is complete
				
								
				if (ID_Done == 1)
					begin
					// Multiply identity matrix by other matrix
						RM[0][0] = (IM1[0][0]*ID[0][0]) + (IM1[0][1]*ID[1][0]) + (IM1[0][2]*ID[2][0]) + (IM1[0][3]*ID[3][0]); // Row 0
						RM[0][1] = (IM1[0][0]*ID[0][1]) + (IM1[0][1]*ID[1][1]) + (IM1[0][2]*ID[2][1]) + (IM1[0][3]*ID[3][1]);	
						RM[0][2] = (IM1[0][0]*ID[0][2]) + (IM1[0][1]*ID[1][2]) + (IM1[0][2]*ID[2][2]) + (IM1[0][3]*ID[3][2]);
						RM[0][3] = (IM1[0][0]*ID[0][3]) + (IM1[0][1]*ID[1][3]) + (IM1[0][2]*ID[2][3]) + (IM1[0][3]*ID[3][3]);
							
						RM[1][0] = (IM1[1][0]*ID[0][0]) + (IM1[1][1]*ID[1][0]) + (IM1[1][2]*ID[2][0]) + (IM1[1][3]*ID[3][0]); // Row 1
						RM[1][1] = (IM1[1][0]*ID[0][1]) + (IM1[1][1]*ID[1][1]) + (IM1[1][2]*ID[2][1]) + (IM1[1][3]*ID[3][1]);
						RM[1][2] = (IM1[1][0]*ID[0][2]) + (IM1[1][1]*ID[1][2]) + (IM1[1][2]*ID[2][2]) + (IM1[1][3]*ID[3][2]);
						RM[1][3] = (IM1[1][0]*ID[0][3]) + (IM1[1][1]*ID[1][3]) + (IM1[1][2]*ID[2][3]) + (IM1[1][3]*ID[3][3]);
									
						RM[2][0] = (IM1[2][0]*ID[0][0]) + (IM1[2][1]*ID[1][0]) + (IM1[2][2]*ID[2][0]) + (IM1[2][3]*ID[3][0]); // Row 2
						RM[2][1] = (IM1[2][0]*ID[0][1]) + (IM1[2][1]*ID[1][1]) + (IM1[2][2]*ID[2][1]) + (IM1[2][3]*ID[3][1]);
						RM[2][2] = (IM1[2][0]*ID[0][2]) + (IM1[2][1]*ID[1][2]) + (IM1[2][2]*ID[2][2]) + (IM1[2][3]*ID[3][2]);
						RM[2][3] = (IM1[2][0]*ID[0][3]) + (IM1[2][1]*ID[1][3]) + (IM1[2][2]*ID[2][3]) + (IM1[2][3]*ID[3][3]);
									
						RM[3][0] = (IM1[3][0]*ID[0][0]) + (IM1[3][1]*ID[1][0]) + (IM1[3][2]*ID[2][0]) + (IM1[3][3]*ID[3][0]); // Row 3
						RM[3][1] = (IM1[3][0]*ID[0][1]) + (IM1[3][1]*ID[1][1]) + (IM1[3][2]*ID[2][1]) + (IM1[3][3]*ID[3][1]);
						RM[3][2] = (IM1[3][0]*ID[0][2]) + (IM1[3][1]*ID[1][2]) + (IM1[3][2]*ID[2][2]) + (IM1[3][3]*ID[3][2]);
						RM[3][3] = (IM1[3][0]*ID[0][3]) + (IM1[3][1]*ID[1][3]) + (IM1[3][2]*ID[2][3]) + (IM1[3][3]*ID[3][3]);
						Math_Done = 1;
					end
				end
			TRANS:
				begin
				// Transpose operation
					RM[0][0] = IM1[0][0];
					RM[0][1] = IM1[1][0];
					RM[0][2] = IM1[2][0];
					RM[0][3] = IM1[3][0];
					
					RM[1][0] = IM1[0][1];
					RM[1][1] = IM1[1][1];
					RM[1][2] = IM1[2][1];
					RM[1][3] = IM1[3][1];
					
					RM[2][0] = IM1[0][2];
					RM[2][1] = IM1[1][2];
					RM[2][2] = IM1[2][2];
					RM[2][3] = IM1[3][2];
					
					RM[3][0] = IM1[0][3];
					RM[3][1] = IM1[1][3];
					RM[3][2] = IM1[2][3];
					RM[3][3] = IM1[3][3];
					Math_Done = 1;
				end  
				
			MULTI:
				begin	
					// multiplication section // dot products
					RM[0][0] = (IM1[0][0]*IM2[0][0]) + (IM1[0][1]*IM2[1][0]) + (IM1[0][2]*IM2[2][0]) + (IM1[0][3]*IM2[3][0]); // Row 0
					RM[0][1] = (IM1[0][0]*IM2[0][1]) + (IM1[0][1]*IM2[1][1]) + (IM1[0][2]*IM2[2][1]) + (IM1[0][3]*IM2[3][1]);	
					RM[0][2] = (IM1[0][0]*IM2[0][2]) + (IM1[0][1]*IM2[1][2]) + (IM1[0][2]*IM2[2][2]) + (IM1[0][3]*IM2[3][2]);
					RM[0][3] = (IM1[0][0]*IM2[0][3]) + (IM1[0][1]*IM2[1][3]) + (IM1[0][2]*IM2[2][3]) + (IM1[0][3]*IM2[3][3]);
                                          
					RM[1][0] = (IM1[1][0]*IM2[0][0]) + (IM1[1][1]*IM2[1][0]) + (IM1[1][2]*IM2[2][0]) + (IM1[1][3]*IM2[3][0]); // Row 1
					RM[1][1] = (IM1[1][0]*IM2[0][1]) + (IM1[1][1]*IM2[1][1]) + (IM1[1][2]*IM2[2][1]) + (IM1[1][3]*IM2[3][1]);
					RM[1][2] = (IM1[1][0]*IM2[0][2]) + (IM1[1][1]*IM2[1][2]) + (IM1[1][2]*IM2[2][2]) + (IM1[1][3]*IM2[3][2]);
					RM[1][3] = (IM1[1][0]*IM2[0][3]) + (IM1[1][1]*IM2[1][3]) + (IM1[1][2]*IM2[2][3]) + (IM1[1][3]*IM2[3][3]);
                                              
					RM[2][0] = (IM1[2][0]*IM2[0][0]) + (IM1[2][1]*IM2[1][0]) + (IM1[2][2]*IM2[2][0]) + (IM1[2][3]*IM2[3][0]); // Row 2
					RM[2][1] = (IM1[2][0]*IM2[0][1]) + (IM1[2][1]*IM2[1][1]) + (IM1[2][2]*IM2[2][1]) + (IM1[2][3]*IM2[3][1]);
					RM[2][2] = (IM1[2][0]*IM2[0][2]) + (IM1[2][1]*IM2[1][2]) + (IM1[2][2]*IM2[2][2]) + (IM1[2][3]*IM2[3][2]);
					RM[2][3] = (IM1[2][0]*IM2[0][3]) + (IM1[2][1]*IM2[1][3]) + (IM1[2][2]*IM2[2][3]) + (IM1[2][3]*IM2[3][3]);
                                             
					RM[3][0] = (IM1[3][0]*IM2[0][0]) + (IM1[3][1]*IM2[1][0]) + (IM1[3][2]*IM2[2][0]) + (IM1[3][3]*IM2[3][0]); // Row 3
					RM[3][1] = (IM1[3][0]*IM2[0][1]) + (IM1[3][1]*IM2[1][1]) + (IM1[3][2]*IM2[2][1]) + (IM1[3][3]*IM2[3][1]);
					RM[3][2] = (IM1[3][0]*IM2[0][2]) + (IM1[3][1]*IM2[1][2]) + (IM1[3][2]*IM2[2][2]) + (IM1[3][3]*IM2[3][2]);
					RM[3][3] = (IM1[3][0]*IM2[0][3]) + (IM1[3][1]*IM2[1][3]) + (IM1[3][2]*IM2[2][3]) + (IM1[3][3]*IM2[3][3]);
					Math_Done = 1;
				end
			
		endcase
	end // end always
	
always @(posedge Math_Done)				
	begin			
				// Rolling up Result matrix (changing from 4x4x16 to 256-bit variable to send on bus)
				MemMatOut[15:0] 	 = RM[0][0];
				MemMatOut[31:16]   	 = RM[0][1];
				MemMatOut[47:32]   	 = RM[0][2];
				MemMatOut[63:48]   	 = RM[0][3];
				
				MemMatOut[79:64]   	 = RM[1][0];
				MemMatOut[95:80]   	 = RM[1][1];
				MemMatOut[111:96]  	 = RM[1][2];
				MemMatOut[127:112] 	 = RM[1][3];
				
				MemMatOut[143:128] 	 = RM[2][0];
				MemMatOut[159:144] 	 = RM[2][1];
				MemMatOut[175:160] 	 = RM[2][2];
				MemMatOut[191:176] 	 = RM[2][3];
				
				MemMatOut[207:192] 	 = RM[3][0];
				MemMatOut[223:208] 	 = RM[3][1];
				MemMatOut[239:224]	 = RM[3][2];
				MemMatOut[255:240] 	 = RM[3][3];

				FinishFlag = 1; // Output signal that computation is complete
	end // end always

endmodule