`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------------
// DSN
//
// Digital Serial Number Reader
// 12/18/01 Initial
// 12/19/01 Cycle time is now the same for write 1 and write 0, >120us
// 03/12/02 Replaced library calls with behavioral code
// 12/04/03 Added non-bidir I/Os for RAT
// 12/11/03 Add global reset
// 04/26/04 Rename gbl_reset
// 09/22/06 Mod for xst
// 09/29/06 Add ratmode disconnect for dsn_io
// 04/27/09 Add safe implementation to state machine
// 08/11/09 Modify to use 1x clock instead of 1/4x vme clock
//--------------------------------------------------------------------------------------------------------------
	module dsn(clock,global_reset,start,dsn_io,dsn_in_rat,dsn_out_rat,wr_data,wr_init,busy,rd_data,dsn_sump);

// Passed from caller
	parameter RATMODE	=	0;			// 0=for TMB and Mez, 1 for RAT

// Static
	parameter MXCNT		=	17;			// Main counter dimension
	parameter MXEND		=	5;			// End counter width, log2(mxcnt)+1
	parameter CNT_BUSY	=	16;			// Init  busy duration
	parameter CNT_INIT	=	15;			// Init  pulse duration,          low for 900 uS
	parameter CNT_SLOT	=	13;			// Slot duration				  low for >120us
	parameter CNT_LONG	=	12;			// Long  pulse duration, logic 0, low for 102 uS
	parameter CNT_SHORT	=	6;			// Short pulse duration, logic 1, low for 1.6 uS
	parameter CNT_READ	=	8;			// Master Read delay              latch at 12 uS

// Ports
	input 				clock;			// 40MHz clock
	input				global_reset;	// Global reset
	input				start;			// Begin counting
	inout				dsn_io;			// DSN chip I/O pin
	input				dsn_in_rat;		// Non-bidir input  for RAT
	output				dsn_out_rat;	// Non-bidir output for RAT
	input				wr_data;		// DSN data bit to output
	input				wr_init;		// DSN init mode
	output				busy;			// DSN chip is busy
	output				rd_data;		// DSN data read from chip
	output				dsn_sump;		// Unused signals

// Local
	wire				count_done;
	wire				write_done;
	wire				latch_data;
	wire				dsn_in;
	reg					dsn_out;
	reg					rd_data;
	reg		[MXEND-1:0]	end_count;
	reg		[MXEND-1:0]	end_write;

// State Machine declarations
	reg [5:0] dsn_sm;	// synthesis attribute safe_implementation of dsn_sm is "yes";

	parameter idle		=	0;
	parameter pulse		=	1;
	parameter wait1		=	2;
	parameter latch		=	3;
	parameter hold		=	4;
	parameter unstart	=	5;

// Bidir DSN I/O pins
	assign dsn_io = (dsn_out | RATMODE) ? ~dsn_out : 1'bz;	// Open drain
	assign dsn_in = (RATMODE) ? dsn_in_rat : dsn_io;		// RAT is non-bidir
	assign dsn_out_rat	= ~dsn_out;							// RAT is non-bidir

	assign dsn_sump = dsn_in_rat | dsn_io;					// Occupy unused inputs

// Output Pulse-width-modulated FF
	always @(posedge clock) begin
	if (write_done)	dsn_out <= 0;
	else			dsn_out <= (dsn_sm==pulse) || dsn_out;
	end

// Main Counter
	reg	[MXCNT-1:0] count;

	assign busy  = dsn_sm != idle & dsn_sm != unstart;

	always @(posedge clock) begin
	if		(dsn_sm==idle) count <= 0;
	else if (busy        ) count <= count + 1; 
	end

// Terminal count controls pulse width
	always @(wr_data or wr_init) begin
	if (wr_init == 1'b1) begin
	 end_count=CNT_BUSY;
	 end_write=CNT_INIT;
	end
	else if (wr_data == 1'b0) begin
	 end_count=CNT_SLOT;
	 end_write=CNT_LONG;
	end
	else if (wr_data == 1'b1) begin
	 end_count=CNT_SLOT;
	 end_write=CNT_SHORT;
	end
	end

	assign count_done = count[end_count];
	assign write_done = count[end_write];
	assign latch_data = count[CNT_READ];

// Latch data bit from DSN chip after dsn_io deasserts. And-gate forces FF into CLB, IOB pair has clock conflict in virtex2
	always @(posedge clock) begin
	if (dsn_sm==latch) rd_data <= dsn_in && (dsn_sm==latch);
	end

// DSN State Machine
	always @(posedge clock) begin
	if(global_reset)
	dsn_sm = idle;
	else begin
	case (dsn_sm)

	idle:
	 if (start)
	 dsn_sm	=	pulse;

	pulse:
	 dsn_sm	=	wait1;

	wait1:
	 if (latch_data)
	 dsn_sm	=	latch;

	latch:
	 dsn_sm =	hold;

	hold:
	 if (count_done)
	 dsn_sm	=	unstart;

	unstart:
	 if (!start)
	 dsn_sm	=	idle;
	endcase
	end
	end

//--------------------------------------------------------------------------------------------------------------
	endmodule
//--------------------------------------------------------------------------------------------------------------
