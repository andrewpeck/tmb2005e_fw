`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// Dual port Block RAM for header data
//	Port A: write-only
//	Port B: read-only
//
//	Uses library RAMB16_S9_S9 instead of inferred RAM,
//	because XST issues spurious warnings for unconnected Port A parity bits.
//	
//	10/26/07 Initial
//	11/01/07 Add port b enable to prevent port a address collisions when not reading port b
//-------------------------------------------------------------------------------------------------------------------
	module ramblock
	(
	clock,
	wr_wea,
	wr_adra,
	wr_dataa,
	rd_enb,
	rd_adrb,
	rd_datab,
	dang
	);

//-------------------------------------------------------------------------------------------------------------------
// Generics caller may override
//-------------------------------------------------------------------------------------------------------------------
	parameter RAM_WIDTH = 9;				// Data width+parity
	parameter RAM_ADRB 	= 11;				// Address bits

//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
	input					clock;			// Write clock

	input					wr_wea;			// Write enable			port A
	input	[RAM_ADRB-1:0]	wr_adra;		// Read/Write address	port A
	input	[RAM_WIDTH-1:0]	wr_dataa;		// Write data 			port A

	input					rd_enb;			// Read enable			port B
	input	[RAM_ADRB-1:0]	rd_adrb;		// Read/Write address	port B
	output	[RAM_WIDTH-1:0]	rd_datab;		// Read  data			port B
	output					dang;			// Dangling pin sump	port A/B

//-------------------------------------------------------------------------------------------------------------------
// Expand data bus widths for an integer number of S9 RAMs
//-------------------------------------------------------------------------------------------------------------------
	parameter s9    = 9;					// Bits per RAM
	parameter nrams = (RAM_WIDTH-1)/s9+1;	// Number of RAMs needed for that many bits
	parameter nbits = nrams*s9;				// Number of bits to span those RAMs
	parameter ndang = nbits-RAM_WIDTH;		// Number of dangling outputs

	initial $display("width= %d",RAM_WIDTH);
	initial $display("nrams= %d",nrams);
	initial $display("nbits= %d",nbits);
	initial $display("ndang= %d",ndang);

// Extend input arrays to be integer multiples of s9
	wire [nbits-1:0] wr_dataax;						// Extended 1D array with leading 0s
	wire [nbits-1:0] rd_databx;						// Extended 1D array with leading 0s
	wire [s9-1:0] wr_dataax2d [nrams-1:0];			// Extended 2D array for gen loop
	wire [s9-1:0] rd_databx2d [nrams-1:0];			// Extended 2D array for gen loop
	assign wr_dataax=wr_dataa;						// Add leading 0s to incoming array
	
// Generate RAMB16_s9_s9s, avoids xst issues for inferred rams with unconnected doa and dopa, so use this library ram
	wire [nrams-1:0] dopa;							// XST issues spurious warning if dopa is not used

	genvar i;
	generate
	for (i=0; i<=nrams-1; i=i+1) begin: ram
	assign wr_dataax2d[i] = wr_dataax[i*s9+s9-1:i*s9];// Map incoming 1D array to 2D for loop
	
	RAMB16_S9_S9 #(
	.WRITE_MODE_A		 ("WRITE_FIRST" ),		// WRITE_FIRST, READ_FIRST or NO_CHANGE
	.WRITE_MODE_B		 ("READ_FIRST"  ),		// WRITE_FIRST, READ_FIRST or NO_CHANGE
	.SIM_COLLISION_CHECK ("GENERATE_X_ONLY")	// "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL
	) uram (
	.WEA	(wr_wea),							// Port A Write Enable Input
	.ENA	(1'b1),								// Port A RAM Enable Input
	.SSRA	(1'b0),								// Port A Synchronous Set/Reset Input
	.CLKA	(clock),							// Port A Clock
	.ADDRA	(wr_adra),							// Port A 11-bit Address Input
	.DIA	(wr_dataax2d[i][7:0]),				// Port A 8-bit Data Input
	.DIPA	(wr_dataax2d[i][8]),				// Port A 1-bit parity Input
	.DOA	(),									// Port A 8-bit Data Output
	.DOPA	(dopa[i]),							// Port A 1-bit Parity Output

	.WEB	(1'b0),								// Port B Write Enable Input
	.ENB	(rd_enb),							// Port B RAM Enable Input
	.SSRB	(1'b0),								// Port B Synchronous Set/Reset Input
	.CLKB	(clock),							// Port B Clock
	.ADDRB	(rd_adrb),							// Port B 11-bit Address Input
	.DIB	(),									// Port B 8-bit Data Input
	.DIPB	(),									// Port B 1-bit parity Input
	.DOB	(rd_databx2d[i][7:0]),				// Port B 8-bit Data Output
	.DOPB	(rd_databx2d[i][8]));				// Port B 1-bit Parity Output

	assign rd_databx[i*s9+s9-1:i*s9]=rd_databx2d[i];// Map outgoing 2D array back to 1D
	end
	endgenerate

	assign rd_datab = rd_databx;					// De-scope extended array to trim leading 0s

// Sump dangling pins
	wire danga = (|dopa);							// All port a parity pins, xst issues spurious warn if you dont use
	wire dangb = rd_databx[nbits-1:nbits-ndang-1];	// Left over port b pins
	
	assign dang = (danga | dangb);

//-------------------------------------------------------------------------------------------------------------------
	endmodule
//-------------------------------------------------------------------------------------------------------------------
