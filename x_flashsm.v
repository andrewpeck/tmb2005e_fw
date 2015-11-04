`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
//
// LED Flash Pulse Generator
//
// Produces a 13mS pulse on trigger's rising edge by dividing
// the 40MHZ clock by 2*19.
//
// 11/21/97 Initial
// 02/03/98 Added output persistence
// 03/26/98 Added reset f/f, reduced output width to 13mS
// 06/08/99 Ported from LCT48 version. Moved trigger from clk to d input
// 08/17/99 Added hold state
// 10/04/01 Converted to Verilog
// 10/04/01 Changed to synchronous design
// 10/16/01 Changed to x_dff
// 10/19/01 Changed to x_counter
// 11/26/01 Fixed trigger x_dff call
// 03/08/02 Replaced library calls with behavioral code
// 09/23/05 Mod for ISE 7.1i
// 09/23/05 Re-write as state machine
// 09/28/06 XST 8.2 mods, x_flash(11) becomes x_flashsm(19) for same 13ms flash
// 04/26/10 Mod for xst 11
//------------------------------------------------------------------------------------------------------------------
	module x_flashsm (trigger,hold,clock,out);

// Generic
	parameter MXCNT = 19;			// Persistence counter size

// Ports
	input			trigger;		// Start flash
	input			hold;			// Hold led on
	input			clock;			// Counter clock
	output			out;			// LED drive

// State Machine declaration
	reg [2:0] flash_sm;
	parameter idle	= 0;
	parameter flash	= 1;
	parameter hwait	= 2;

	// synthesis attribute safe_implementation of flash_sm is "yes";
	// synthesis attribute init                of flash_sm is idle;

// Buffer input
	reg trig_ff;
	reg hold_ff;

	always @(posedge clock) begin
	trig_ff <= trigger;
	hold_ff	<= hold | trigger;
	end

// Buffer output
	reg out;

	always @(posedge clock) begin
	out <= (flash_sm != idle);
	end

// Flash persistence counter
	reg [MXCNT:0] cnt;

	always @(posedge clock) begin
	if (flash_sm != flash)	cnt = 0;
	else					cnt = cnt + 1'b1;
	end

	wire cnt_done = cnt[MXCNT];

// Flash state machine
	wire sm_reset = !((flash_sm==idle) || (flash_sm==flash) || (flash_sm==hwait));

	always @(posedge clock) begin
	if (sm_reset) flash_sm = idle;
	else begin
	case (flash_sm)
	idle:	if (trig_ff)	flash_sm = flash;
	flash:	if (cnt_done)	flash_sm = hwait;
	hwait:	if (!hold_ff)	flash_sm = idle;
	endcase
	end
	end

//------------------------------------------------------------------------------------------------------------------
	endmodule
//------------------------------------------------------------------------------------------------------------------
