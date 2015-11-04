`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
// Digital One-Shot:
//		Produces 1-clock wide pulse when d goes high.
//		Waits for d to go low before re-triggering.
//
//	02/07/02 Initial
//	09/15/06 Mod for xst
//	01/13/09 Mod for ise 10.1i
//-----------------------------------------------------------------------------------------------------------------
	module x_oneshot (d,clock,q);

	input	d;
	input	clock;
	output	q;

// State Machine declarations
	reg		[2:0]		sm;	// synthesis attribute safe_implementation of sm is "yes";
	parameter idle	=	0;
	parameter pulse	=	1;
	parameter hold	=	2;

// One-shot state machine
	initial sm = idle;

	always @(posedge clock) begin
 	case (sm)
	
	idle:
		if (d)
		sm = pulse;

	pulse:
		sm = hold;

	hold:
		if(!d)
		sm = idle;

	default:
		sm = idle;

	endcase
	end

// Output FF
	reg	q = 0;

	always @(posedge clock) begin
	q <= (sm==pulse);
	end

//------------------------------------------------------------------------------------------------------------------
	endmodule
//------------------------------------------------------------------------------------------------------------------
