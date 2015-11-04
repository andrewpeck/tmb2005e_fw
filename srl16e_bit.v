`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------
//
//	Variable depth, single bit SRL16E-based parallel shifter
//
//	06/25/10 Initial
//-----------------------------------------------------------------------------------------------------------------------
	module srl16e_bit(clock,adr,d,q);

// Generic
	parameter ADR_WIDTH = 8;		// Addess width
	parameter SRL_DEPTH = 256;		// Shift register stages may be less than 2**ADR_WIDTH

// Ports
	input					clock;
	input	[ADR_WIDTH-1:0]	adr;
	input					d;
	output					q;

// Callers parameter list
	initial	$display ("srl16e_bit ADR_WIDTH=%d SRL_DEPTH=%d",ADR_WIDTH,SRL_DEPTH);

// Shift d left by adr places
	reg [SRL_DEPTH-1:0] srl;

	always @(posedge clock) begin
	srl <= {srl[SRL_DEPTH-2:0], d};
	end

	assign q = srl[adr];
	
//-----------------------------------------------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------------------------------------------------
