`include "../firmware_version.v"

`ifdef VIRTEX6
`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------//
// Virtex6: 2-to-1 Multiplexer converts 40MHz data to 80MHz
//-----------------------------------------------------------------------------------------------------------------------//
//	07/13/10 Port to ise 12
//	07/30/10 Same_edge mode eliminates holding ffs
//	07/14/10 Mod port order
//	11/30/10 Add virtex2|6 selection
//-----------------------------------------------------------------------------------------------------------------------
	module x_mux_ddr_mpc (clock,clock_en,set,din1st,din2nd,dout);

// Generic
	parameter WIDTH = 8;
	initial	$display("x_mux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
	input				clock;			// 40 MHz clock
	input				clock_en;		// Clock enable
	input				set;			// Sync set
	input	[WIDTH-1:0]	din1st;			// Input data 1st-in-time
	input	[WIDTH-1:0]	din2nd;			// Input data 2nd-in-time
	output	[WIDTH-1:0]	dout;			// Output data multiplexed 2-to-1

// Generate array of output DDRs, xst can not infer ddr outputs
	genvar i;
	generate
	for (i=0; i<=WIDTH-1; i=i+1) begin: oddr_gen
	ODDR #(
	.DDR_CLK_EDGE ("SAME_EDGE"),		// "OPPOSITE_EDGE" or "SAME_EDGE"
	.INIT         (1'b1),				// Initial value of Q: 1'b0 or 1'b1
	.SRTYPE       ("SYNC")				// Set/Reset type: "SYNC" or "ASYNC"
     ) u0 (
	.C	(clock),						// 1-bit clock input
	.CE	(clock_en),						// 1-bit clock enable input
	.S	(set),							// 1-bit set
	.R	(1'b0),							// 1-bit reset
	.D1	(din1st[i]),					// 1-bit data input (positive edge)
	.D2	(din2nd[i]),					// 1-bit data input (negative edge)
	.Q	(dout[i]));						// 1-bit DDR output
	end
	endgenerate

//-----------------------------------------------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------------------------------------------------


`elsif VIRTEX2
`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------//
// Virtex2: 2-to-1 Multiplexer converts 40MHz data to 80MHz
//-----------------------------------------------------------------------------------------------------------------------//
//	12/03/01 Initial
//	03/03/02 Replaced library FFs with behavioral FFs
//	01/29/03 Added async set to blank /mpc output at startup
//	09/19/06 Mod for xst
//	10/10/06 Convert to ddr for virtex2
//	01/22/08 NB all virtex2 ddr outputs power up as 0 during GSR, the init attribute can not be applied
//	07/14/10 Mod port order to conform to virtex 6 version
//-----------------------------------------------------------------------------------------------------------------------
	module x_mux_ddr_mpc (clock,clock_en,set,din1st,din2nd,dout);

// Generic
	parameter WIDTH = 8;
	initial	$display("x_mux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
	input				clock;			// 40 MHz clock
	input				clock_en;		// Clock enable
	input				set;			// Async set
	input	[WIDTH-1:0]	din1st;			// Input data 1st-in-time
	input	[WIDTH-1:0]	din2nd;			// Input data 2nd-in-time
	output	[WIDTH-1:0]	dout;			// Output data multiplexed 2-to-1

// Latch second time slice to a holding FF FDCPE so dout will be aligned with 40MHz clock
	reg [WIDTH-1:0]	din2nd_ff = 0;

	always @(posedge clock or posedge set) begin
	if (set) din2nd_ff <= {WIDTH{1'b1}};// async preset
	else     din2nd_ff <= din2nd;		// sync  store
	end

// Generate array of output DDRs, xst can not infer ddr outputs
	genvar i;
	generate
	for (i=0; i<=WIDTH-1; i=i+1) begin: oddr_gen
	OFDDRTCPE u0 (
	.C0		(clock),					// 0 degree clock input
	.C1		(!clock),					// 180 degree clock input
	.CE		(clock_en),					// Clock enable input
	.CLR	(1'b0),						// Asynchronous reset input
	.PRE	(set),						// Asynchronous preset input
	.T		(1'b0),						// 0=3-state enable input
	.D0		(din1st[i]),				// Posedge data input
	.D1		(din2nd_ff[i]),				// Negedge data input
	.O		(dout[i]));					// Data output (connect directly to top-level port)
	end
	endgenerate

//-----------------------------------------------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------------------------------------------------

`endif
