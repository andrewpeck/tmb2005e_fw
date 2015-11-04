`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------------
//	Cylon sequence generator, one eye
//
//	10/01/03 Initial
//	09/28/06 Mod xst remove output ff, inferred ROM is already registered
//	10/10/06 Replace init ff with srl
//	05/21/07 Rename cylon9 to cylon1 to distinguish from 2-eye, add rate
//	08/11/09 Replace 10MHz clock_vme with  40MHz clock, increase prescale counter by 2 bits
//--------------------------------------------------------------------------------------------------------------
	module cylon1 (clock,rate,q);

// Ports
	input 			clock;
	input	[1:0]	rate;
	output	[7:0]	q;

// Initialization
	wire [3:0]	pdly = 0;
	wire		init;

	SRL16E uinit (.CLK(clock),.CE(!init),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(init));

// Scale clock down below visual fusion
	parameter MXPRE = 21;
	reg	[MXPRE-1:0]	prescaler = 0;

	always @(posedge clock) begin
	prescaler = prescaler+rate[1:0]+1;
	end
 
	wire next = (prescaler == 0);

// Point runs 0 to 14
	reg	[3:0]	pointer=0;

	always @(posedge clock) begin
	if (next) begin
	if		(pointer==13) pointer = 0;
	else if (init       ) pointer = pointer + 1;
	end
	end

// Display pattern selected by pointer
	reg	[7:0] display;

	always @(pointer) begin
	case (pointer)
	0:	display	<=	8'b00000001;
	1:	display	<=	8'b00000010;
	2:	display	<=	8'b00000100;
	3:	display	<=	8'b00001000;
	4:	display	<=	8'b00010000;
	5:	display	<=	8'b00100000;
	6:	display	<=	8'b01000000;
	7:	display	<=	8'b10000000;
	8:	display	<=	8'b01000000;
	9:	display	<=	8'b00100000;
	10:	display	<=	8'b00010000;
	11:	display	<=	8'b00001000;
	12:	display	<=	8'b00000100;
	13:	display	<=	8'b00000010;
	14:	display	<=	8'b00000001;
	15:	display	<=	8'b11111111;
	endcase
	end

	assign q = display;

//--------------------------------------------------------------------------------------------------------------
	endmodule
//--------------------------------------------------------------------------------------------------------------
