`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------
// Parameterized programmable delay
//
//	06/14/02 Initial
//	09/18/06 Mod for XST
//	09/25/06 change to while loop
//-----------------------------------------------------------------------------------------------------------------
	module x_delay (d,clock,delay,q);
	parameter MXDLY	=	4;				// Number delay value bits
	parameter MXSR	=	1 << MXDLY;		// Number delay stages

// IOs
	input				d;
	input				clock;
	input	[MXDLY-1:0]	delay;
	output				q;

// Delay stages
	reg	[MXSR-1:1] sr;
	integer i;
	
	always @(posedge clock) begin
	sr[1] <= d;
	i=2;
	while (i<MXSR) begin
	sr[i] <= sr[i-1];
	i=i+1;
 	end
	end

// Select delayed output
	wire [MXSR-1:0] srq;

	assign srq[0]		 = d;
	assign srq[MXSR-1:1] = sr;

	assign q = srq[delay];

//-----------------------------------------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------------------------------------------
