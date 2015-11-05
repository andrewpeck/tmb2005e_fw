`include "../firmware_version.v"

`ifdef VIRTEX6
`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------
// Virtex6: 1-to-2 De-multiplexer converts 80MHz data to 40MHz
//--------------------------------------------------------------------------------------------------------
//	07/21/10 Port to ise 12
//	07/22/10 Use same_edge_pipelined to give same timing as virtex 2 version
//	11/30/10 Add virtex2|6 selection
//--------------------------------------------------------------------------------------------------------
	module x_demux_ddr_mpc (clock,set,din,dout1st,dout2nd);

// Generic
	parameter WIDTH = 8;
	initial	$display("x_demux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
	input				clock;
	input				set;
	input	[WIDTH-1:0]	din;
	output	[WIDTH-1:0]	dout1st;
	output	[WIDTH-1:0]	dout2nd;

// Generate array of input DDRs, pipepline stage adds 1bx which matches extra legacy delay FFs in virtex 2 version
	genvar i;
	generate
	for (i=0; i<=WIDTH-1; i=i+1) begin: iddr_gen
	IDDR #(
	.DDR_CLK_EDGE	("SAME_EDGE_PIPELINED"),	// "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
	.INIT_Q1		(1'b1),						// Initial value of Q1: 1'b0 or 1'b1
	.INIT_Q2		(1'b1),						// Initial value of Q2: 1'b0 or 1'b1
	.SRTYPE			("SYNC")					// Set/Reset type: "SYNC" or "ASYNC"
	) u0 (
	.C	(clock),			// 1-bit clock input
	.CE	(1'b1),				// 1-bit clock enable input
	.R	(1'b0),				// 1-bit reset
	.S	(set),				// 1-bit set
	.D	(din[i]),			// 1-bit DDR data input
	.Q1	(dout1st[i]),		// 1-bit output for positive edge of clock
	.Q2	(dout2nd[i]));		// 1-bit output for negative edge of clock
	end
	endgenerate

//--------------------------------------------------------------------------------------------------------
	endmodule
//--------------------------------------------------------------------------------------------------------


`elsif VIRTEX2
`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------
// Virtex2: 1-to-2 De-multiplexer converts 80MHz data to 40MHz
//--------------------------------------------------------------------------------------------------------
// 12/03/01 Initial
// 01/29/02 Added aclr input
// 03/03/02 Replaced library FFs with behavioral FFs
// 06/04/04 Add async set for MPC receiver
// 09/19/06 Mod for xst
// 10/06/06 Convert to DDR
// 07/15/10 Conform port order to Virtex 6 version, change to non-blocking operators
//--------------------------------------------------------------------------------------------------------
	module x_demux_ddr_mpc (clock,set,din,dout1st,dout2nd);

// Generic
	parameter WIDTH = 8;
	initial	$display("x_demux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
	input				clock;
	input				set;
	input	[WIDTH-1:0]	din;
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
	always @(posedge clock or posedge set) begin	// Latch 1st-in-time on rising edge
	if (set) din1st <= {WIDTH{1'b1}};				// async set
	else     din1st <= din;							// sync  store
	end

	always @(negedge clock or posedge set) begin	// Latch 2nd-in-time on falling edge
	if (set) din2nd <= {WIDTH{1'b1}};				// async set
	else     din2nd <= din;							// sync  store
	end

// Latch first and second time slices into 40MHz FFs FDCPE
// These are unnecessary legacy FFs to give DDR same timing as old  x_demux
	always @(posedge clock or posedge set) begin
	if (set) dout1st <= {WIDTH{1'b1}};				// async set
	else     dout1st <= din1st;						// sync  store
	end

	always @(posedge clock or posedge set) begin
	if (set) dout2nd <= {WIDTH{1'b1}};				// async set
	else     dout2nd <= din2nd;						// sync  store
	end

//--------------------------------------------------------------------------------------------------------
	endmodule
//--------------------------------------------------------------------------------------------------------

`endif
