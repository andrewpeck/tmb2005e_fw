`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------
//
//	Cylon sequence generator, two-eye
//
//	10/01/03 Initial
//	09/28/06 Mod xst remove output ff, inferred ROM is already registered
//	10/10/06 Replace init ff with srl
//	05/16/07 Port from cylon9, add rate
//	08/11/09 Replace 10MHz clock_vme with  40MHz clock, increase prescale counter by 2 bits
//--------------------------------------------------------------------------------------------------------
	module cylon2 (clock,rate,q);

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

// ROM address
	reg	[2:0] adr = 0;

	always @(posedge clock) begin
	if (next) begin
	if		(adr==6) adr = 0;
	else if (init  ) adr = adr + 1;
	end
	end

// ROM pattern LUT
	reg	[7:0] rom;

	always @(adr) begin
	case (adr)
	0:	rom	<=	8'b01000001;
	1:	rom	<=	8'b00100010;
	2:	rom	<=	8'b00010100;
	3:	rom	<=	8'b00001000;
	4:	rom	<=	8'b00010100;
	5:	rom	<=	8'b00100010;
	6:	rom	<=	8'b01000001;
	7:	rom	<=	8'b11111111;
	endcase
	end

	assign q = rom;

	endmodule
