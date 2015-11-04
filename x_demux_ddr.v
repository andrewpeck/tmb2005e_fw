`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------
//
// 1-to-2 De-multiplexer converts 80MHz data to 40MHz
//
// Notes:
//	1) Parameter WIDTH sets the number of input bits
//	2) clocks must be from a DLL with global-net feedback
//	3) Synthesis must locate din FFs in an IOB
//
// 12/03/01 Initial
// 01/29/02 Added aclr input
// 03/03/02 Replaced library FFs with behavioral FFs
// 06/04/04 Add async set for MPC receiver
// 09/19/06 Mod for xst
// 10/06/06 Convert to DDR
//--------------------------------------------------------------------------------------------------------

	module x_demux_ddr(din,clock,aset,aclr,dout1st,dout2nd);
	parameter WIDTH = 1;
//
	input	[WIDTH-1:0]	din;
	input				clock;
	input				aset;
	input				aclr;
	output	[WIDTH-1:0]	dout1st;
	output	[WIDTH-1:0]	dout2nd;

// Local
	reg		[WIDTH-1:0]	din1st;		// synthesis attribute IOB of din1st is "true"
	reg		[WIDTH-1:0]	din2nd;		// synthesis attribute IOB of din2nd is "true"
	reg		[WIDTH-1:0]	dout1st;
	reg		[WIDTH-1:0]	dout2nd;

// Latch 80 MHz multiplexed inputs in DDR IOB FFs
// Prefer to latch 1st-in-time on falling edge which reduces latency by 1 clock period
// This version latches 1st-in-time on rising edge to preserve latency of old-style mux version
	always @(posedge clock or posedge aset or posedge aclr) begin	// Latch 1st-in-time on rising edge
	if		(aclr)	din1st = {WIDTH{1'b0}};		// async clear
	else if	(aset)	din1st = {WIDTH{1'b1}};		// async set
	else			din1st = din;				// sync  store
	end

	always @(negedge clock or posedge aset or posedge aclr) begin	// Latch 2nd-in-time on falling edge
	if		(aclr)	din2nd = {WIDTH{1'b0}};		// async clear
	else if	(aset)	din2nd = {WIDTH{1'b1}};		// async set
	else			din2nd = din;				// sync  store
	end

// Latch first and second time slices into 40MHz FFs FDCPE
// These are unnecessary legacy FFs to give DDR same timing as old  x_demux
	always @(posedge clock or posedge aset or posedge aclr) begin
	if		(aclr)	dout1st = {WIDTH{1'b0}};	// async clear
	else if	(aset)	dout1st = {WIDTH{1'b1}};	// async set
	else			dout1st = din1st;			// sync  store
	end

	always @(posedge clock or posedge aset or posedge aclr) begin
	if		(aclr)	dout2nd = {WIDTH{1'b0}};	// async clear
	else if	(aset)	dout2nd = {WIDTH{1'b1}};	// async set
	else			dout2nd = din2nd;			// sync  store
	end

//--------------------------------------------------------------------------------------------------------
	endmodule
//--------------------------------------------------------------------------------------------------------
