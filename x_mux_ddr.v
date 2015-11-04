`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------//
// 2-to-1 Multiplexer converts 40MHz data to 80MHz
//
// Notes:
//	1) Parameter WIDTH sets the number of input bits
//	2) clocks must be from a DLL with global-net feedback
//	3) Synthesis must locate dout FFs in an IOB
//	4) Output data is assumed to be sync'd with clock1x
//	5) Only implement 1 of aclr or aset, IOBs have only 1 init
//
//	12/03/01 Initial
//	03/03/02 Replaced library FFs with behavioral FFs
//	01/29/03 Added async set to blank /mpc output at startup
//	09/19/06 Mod for xst
//	10/10/06 Convert to ddr for virtex2
//	01/22/08 NB all virtex2 ddr outputs power up as 0 during GSR, the init attribute can not be applied
//-----------------------------------------------------------------------------------------------------------------------
	module x_mux_ddr(din1st,din2nd,clock,clock_en,noe,aset,aclr,dout);

// Generic
	parameter WIDTH = 1;

// Ports
	input	[WIDTH-1:0]	din1st;			// Input data 1st-in-time
	input	[WIDTH-1:0]	din2nd;			// Input data 2nd-in-time

	input				clock;			// 40 MHz clock
	input				clock_en;		// Clock enable
	input				noe;			// 0=Tri-state enable
	input				aset;			// Async set
	input				aclr;			// Async clear
	output	[WIDTH-1:0]	dout;			// Output data multiplexed 2-to-1

// Latch second time slice to a holding FF FDCPE so dout will be aligned with 40MHz clock
	reg [WIDTH-1:0]	din2nd_ff;

	always @(posedge clock or posedge aclr or posedge aset) begin
	if		(aclr)	din2nd_ff <= {WIDTH{1'b0}};		// async clear
	else if	(aset)	din2nd_ff <= {WIDTH{1'b1}};		// async preset
	else			din2nd_ff <= din2nd;			// sync  store
	end

// Generate array of output DDRs, xst can not infer ddr outputs
	genvar i;
	generate
	for (i=0; i<=WIDTH-1; i=i+1) begin: ddr_gen
	OFDDRTCPE u0 (
	.O		(dout[i]),		// Data output (connect directly to top-level port)
	.C0		(clock),		// 0 degree clock input
	.C1		(!clock),		// 180 degree clock input
	.CE		(clock_en),		// Clock enable input
	.CLR	(aclr),			// Asynchronous reset input
	.D0		(din1st[i]),	// Posedge data input
	.D1		(din2nd_ff[i]),	// Negedge data input
	.PRE	(aset),			// Asynchronous preset input
	.T		(noe));			// 0=3-state enable input
	end
	endgenerate

//-----------------------------------------------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------------------------------------------------
