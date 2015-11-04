`timescale 1ns / 1ps
//`define DEBUG_CLOCK 1
//------------------------------------------------------------------------------------------------------------------
//	Virtex2 Clock DCMs
//------------------------------------------------------------------------------------------------------------------
//	09/30/03 Initial for Virtex2
//	12/11/03 Add global reset
//	09/12/06 Mods for xst
//	09/13/06 Rename rpc_rxalt1 to rpc_dsn
//	09/15/06 Bitgen demands clk_feeback set to 2x
//	10/10/06 Change bufg to bufgmux for virtex2
//	10/10/06 Remove clock_2x, clock_alct_2x
//	05/10/07 Put clock_2x back for new pattern finder mux
//	06/13/07 Add multiplexer output signal for pattern finder
//	06/14/07 Change logic accessible clock input to dcm 90 degree signal
//	05/14/08 Mod global_reset to latch off once DLL locks
//	05/23/08 Mod global_reset to pulse when DLL re-locks, latch lock loss for sync_err
//	06/02/08 Add enable for global_reset on lock-loss
//	03/30/09 Add programmable 1/2 cycle shift for alct inter-stage
//	03/31/09 Tried 3/4 cycle shift
//	04/02/09 No improvement, so reverted to 1/2-cycle
//	05/27/09 Add tmb_rx_clock for incoming alct data with muonic timing
//	06/05/09 Remove non-muonic clock mux to see if it improves good spots
//	06/10/09 Convert to digital phase shifting for alct txd and rxd clocks, totally awesome
//	06/11/09 Change psclk to run continuously from tmb main, add phaser reset
//	06/12/09 Remove interstage clock muxes, do it with lac instead, add dcm reset for phaser
//	06/12/09 Change to mux method for txd rxd because phase amplification idea didnt work
//	06/15/09 Change to -32 to +31 phase range
//	06/16/09 Remove digital phase shifter
//	06/18/09 Add cfeb muonic dcm
//	06/24/09 Put back alct digital phase shifters, add cfeb digital phase shifters
//	06/25/09 Switch from global buffers to FFs for quadrant shifting
//	06/29/09 Remove digital phase shifters for cfebs, certain cfeb IOBs can not have 2 clock domains
//	07/10/09 Return digital phase shifters for cfebs, mod ucf to move 5 IOB DDRs to fabric
//	07/16/09 Add global buffers to phase shifter clocks, constrain dcm and gbuf locs
//	07/17/09 Reassign global buffer and dcm locs per dcm_locator Monte Carlo
//	07/21/09 New gbuf and dcm locs, remove gbufs for alct, add gbufs for cfebs, remove vme gbuf
//	07/22/09 Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//	08/04/09 Add location constraints in ucf for phase shifter mux components
//	08/04/09 Replace digital phase shifter multiplexer code with submodules
//	08/07/09 Relax digital phase shifter quadrant selects maxdelay
//	08/07/09 Remove gbufs for cfeb phase shifted clocks, put vme clock back in
//	08/10/09 Add ffs in clock_mux to transfer dc quadrant selects into 160mhz time domain
//	08/10/09 Swap 2x and vme global buffers to match older versions
//	08/10/09 Add ffs to transfer dc quadrant selects into 40mhz time domain before sending to clock_mux
//	09/11/09 Add quadrant update linked to fire stobe
//	09/18/09 Relocate dcms to shorten clock paths
//	04/27/10 Allow ttc_resync to clear clock_lock_lost
//	05/12/10 Move clock_lock_lost ff to sync_err module, remove ttc_resync
//------------------------------------------------------------------------------------------------------------------
	module clock_virtex2
	(
// Clock inputs
	tmb_clock0,
	tmb_clock0d,
	tmb_clock1,
	alct_rxclock,
	alct_rxclockd,
	mpc_clock,
	dcc_clock,
	rpc_sig,

// Main clock outputs
	clock,
	clock_2x,
	clock_vme,
	clock_lac,

// Phase delayed clocks
	clock_alct_rxd,
	clock_alct_txd,
	clock_cfeb0_rxd,
	clock_cfeb1_rxd,
	clock_cfeb2_rxd,
	clock_cfeb3_rxd,
	clock_cfeb4_rxd,

// Global reset
	global_reset_en,
	global_reset,
	clock_lock_lost_err,

// Clock DCM lock status
	lock_tmb_clock0,
	lock_tmb_clock0d,
	lock_alct_rxclockd,
	lock_mpc_clock,
	lock_dcc_clock,
	lock_rpc_rxalt1,
	lock_tmb_clock1,
	lock_alct_rxclock,

// ALCT_rxd Phaser control/status ports
	fire_alct_rxd,
	reset_alct_rxd,
	hcycle_alct_rxd,
	qcycle_alct_rxd,
	phase_alct_rxd,
	phaser_busy_alct_rxd,
	phaser_sm_alct_rxd,
	lock_alct_rxd,

// ALCT_txd Phaser control/status ports
	fire_alct_txd,
	reset_alct_txd,
	hcycle_alct_txd,
	qcycle_alct_txd,
	phase_alct_txd,
	phaser_busy_alct_txd,
	phaser_sm_alct_txd,
	lock_alct_txd,

// CFEB0_rxd Phaser control/status ports
	fire_cfeb0_rxd,
	reset_cfeb0_rxd,
	hcycle_cfeb0_rxd,
	qcycle_cfeb0_rxd,
	phase_cfeb0_rxd,
	phaser_busy_cfeb0_rxd,
	phaser_sm_cfeb0_rxd,
	lock_cfeb0_rxd,

// CFEB1_rxd Phaser control/status ports
	fire_cfeb1_rxd,
	reset_cfeb1_rxd,
	hcycle_cfeb1_rxd,
	qcycle_cfeb1_rxd,
	phase_cfeb1_rxd,
	phaser_busy_cfeb1_rxd,
	phaser_sm_cfeb1_rxd,
	lock_cfeb1_rxd,

// CFEB2_rxd Phaser control/status ports
	fire_cfeb2_rxd,
	reset_cfeb2_rxd,
	hcycle_cfeb2_rxd,
	qcycle_cfeb2_rxd,
	phase_cfeb2_rxd,
	phaser_busy_cfeb2_rxd,
	phaser_sm_cfeb2_rxd,
	lock_cfeb2_rxd,

// CFEB3_rxd Phaser control/status ports
	fire_cfeb3_rxd,
	reset_cfeb3_rxd,
	hcycle_cfeb3_rxd,
	qcycle_cfeb3_rxd,
	phase_cfeb3_rxd,
	phaser_busy_cfeb3_rxd,
	phaser_sm_cfeb3_rxd,
	lock_cfeb3_rxd,

// CFEB4_rxd Phaser control/status ports
	fire_cfeb4_rxd,
	reset_cfeb4_rxd,
	hcycle_cfeb4_rxd,
	qcycle_cfeb4_rxd,
	phase_cfeb4_rxd,
	phaser_busy_cfeb4_rxd,
	phaser_sm_cfeb4_rxd,
	lock_cfeb4_rxd

// Debug
`ifdef DEBUG_CLOCK
	,dcm_reset
	,psen_alct_rxd
	,psincdec_alct_rxd
	,psdone_alct_rxd
`endif
	);
//------------------------------------------------------------------------------------------------------------------
// Ports
//------------------------------------------------------------------------------------------------------------------
// Clock inputs
	input			tmb_clock0;				// 40MHz clock bypasses 3D3444 and loads Mez PROMs, chip bottom
	input			tmb_clock0d;			// 40MHz clock bypasses 3D3444 and loads Mez PROMs, chip top
	input			tmb_clock1;				// 40MHz clock with 3D3444 delay
	input			alct_rxclock;			// 40MHz ALCT receive data clock with 3D3444 delay, chip bottom
	input			alct_rxclockd;			// 40MHz ALCT receive data clock with 3D3444 delay, chip top
	input			mpc_clock;				// 40MHz MPC clock
	input			dcc_clock;				// 40MHz Duty cycle corrected clock with 3D3444 delay
	input			rpc_sig;				// 40MHz Unused

// Main clock outputs
	output			clock;					// 40MHz global TMB clock 1x
	output			clock_2x;				// 80MHz global TMB clock 2x
	output			clock_vme;				// 10MHz global VME clock 1/4x
	output			clock_lac;				// 40MHz logic accessible clock

// Phase delayed clocks
	output			clock_alct_rxd;			// 40MHz ALCT receive  data clock 1x
	output			clock_alct_txd;			// 40MHz ALCT transmit data clock 1x
	output			clock_cfeb0_rxd;		// 40MHz CFEB receive  data clock 1x
	output			clock_cfeb1_rxd;		// 40MHz CFEB receive  data clock 1x
	output			clock_cfeb2_rxd;		// 40MHz CFEB receive  data clock 1x
	output			clock_cfeb3_rxd;		// 40MHz CFEB receive  data clock 1x
	output			clock_cfeb4_rxd;		// 40MHz CFEB receive  data clock 1x

// Global reset
	input			global_reset_en;		// Enable global reset on lock_lost
	output			global_reset;			// Global reset, asserted until main DLL locks
	output			clock_lock_lost_err;	// 40MHz main clock lost lock FF

// Clock DCM lock status
	output			lock_tmb_clock0;		// DCM lock status
	output			lock_tmb_clock0d;		// DCM lock status
	output			lock_alct_rxclockd;		// DCM lock status
	output			lock_mpc_clock;			// DCM lock status
	output			lock_dcc_clock;			// DCM lock status
	output			lock_rpc_rxalt1;		// DCM lock status
	output			lock_tmb_clock1;		// DCM lock status
	output			lock_alct_rxclock;		// DCM lock status

// ALCT_rxd Phaser VME control/status ports
	input			fire_alct_rxd;			// Set new phase
	input			reset_alct_rxd;			// VME Reset current phase
	input			hcycle_alct_rxd;		// Half    cycle phase shift
	input			qcycle_alct_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_alct_rxd;			// Phase to set, 0-255
	output			phaser_busy_alct_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_alct_rxd;		// Phase shifter machine state
	output			lock_alct_rxd;			// DCM lock status

// ALCT_txd Phaser VME control/status ports
	input			fire_alct_txd;			// Set new phase
	input			reset_alct_txd;			// VME Reset current phase
	input			hcycle_alct_txd;		// Half    cycle phase shift
	input			qcycle_alct_txd;		// Quarter cycle phase shift
	input	[5:0]	phase_alct_txd;			// Phase to set, 0-255
	output			phaser_busy_alct_txd;	// Phase shifter busy
	output	[2:0]	phaser_sm_alct_txd;		// Phase shifter machine state
	output			lock_alct_txd;			// DCM lock status

// CFEB0_rxd Phaser VME control/status ports
	input			fire_cfeb0_rxd;			// Set new phase
	input			reset_cfeb0_rxd;		// VME Reset current phase
	input			hcycle_cfeb0_rxd;		// Half    cycle phase shift
	input			qcycle_cfeb0_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_cfeb0_rxd;		// Phase to set, 0-255
	output			phaser_busy_cfeb0_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_cfeb0_rxd;	// Phase shifter machine state
	output			lock_cfeb0_rxd;			// DCM lock status

// CFEB1_rxd Phaser VME control/status ports
	input			fire_cfeb1_rxd;			// Set new phase
	input			reset_cfeb1_rxd;		// VME Reset current phase
	input			hcycle_cfeb1_rxd;		// Half    cycle phase shift
	input			qcycle_cfeb1_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_cfeb1_rxd;		// Phase to set, 0-255
	output			phaser_busy_cfeb1_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_cfeb1_rxd;	// Phase shifter machine state
	output			lock_cfeb1_rxd;			// DCM lock status

// CFEB2_rxd Phaser VME control/status ports
	input			fire_cfeb2_rxd;			// Set new phase
	input			reset_cfeb2_rxd;		// VME Reset current phase
	input			hcycle_cfeb2_rxd;		// Half    cycle phase shift
	input			qcycle_cfeb2_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_cfeb2_rxd;		// Phase to set, 0-255
	output			phaser_busy_cfeb2_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_cfeb2_rxd;	// Phase shifter machine state
	output			lock_cfeb2_rxd;			// DCM lock status

// CFEB3_rxd Phaser VME control/status ports
	input			fire_cfeb3_rxd;			// Set new phase
	input			reset_cfeb3_rxd;		// VME Reset current phase
	input			hcycle_cfeb3_rxd;		// Half    cycle phase shift
	input			qcycle_cfeb3_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_cfeb3_rxd;		// Phase to set, 0-255
	output			phaser_busy_cfeb3_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_cfeb3_rxd;	// Phase shifter machine state
	output			lock_cfeb3_rxd;			// DCM lock status

// CFEB4_rxd Phaser VME control/status ports
	input			fire_cfeb4_rxd;			// Set new phase
	input			reset_cfeb4_rxd;		// VME Reset current phase
	input			hcycle_cfeb4_rxd;		// Half    cycle phase shift
	input			qcycle_cfeb4_rxd;		// Quarter cycle phase shift
	input	[5:0]	phase_cfeb4_rxd;		// Phase to set, 0-255
	output			phaser_busy_cfeb4_rxd;	// Phase shifter busy
	output	[2:0]	phaser_sm_cfeb4_rxd;	// Phase shifter machine state
	output			lock_cfeb4_rxd;			// DCM lock status

// Debug
`ifdef DEBUG_CLOCK
	input			dcm_reset;				// DCM reset input for simulation, assert for at least 3 cycles
	output			psen_alct_rxd;			// Dps phase shift enable
	output			psincdec_alct_rxd;		// Dps phase increment/decrement
	output			psdone_alct_rxd;		// Dps done
`else
	wire			dcm_reset = 1'b0;		// DCM reset hard-wired to 0 normally
`endif
//-------------------------------------------------------------------------------------------------------------------
// Clock DCM Assignments
//
//	Signal			Pin		Pad		DCM		BUFG	3D3444 Channel	Usage
//	-------------	---		------	----	------	--------------	--------------------------------
//	alct_rxclock	AK17	GCLK0P					Chip 0 Ch 1		ALCT receive, chip bottom
//	alct_rxclockd	H17		GCLK1P					Chip 0 Ch 1		ALCT receive, chip top
//	dcc_clock		AG17	GCLK2P					Chip 1 Ch 2		Duty cycle corrected
//	mpc_clock		E17		GCLK3P					Chip 1 Ch 1		MPC
//	tmb_clock0		AF18	GCLK4P					None			TMB main, chip bottom
//	tmb_clock0d		E19		GCLK5P					None			TMB main, chip top
//	tmb_clock1		AK19	GCLK6P					Chip 1 Ch 0		TMB delayed
//	rpc_dsn			K18		GCLK7P					None			RPC rpc_dsn shared with rat 3d3444 verify
//
//-------------------------------------------------------------------------------------------------------------------
//	Virtex2 DCM global clock buffer rules:
// 
//	A DCM may drive four global clock buffers on the edge (top or bottom) where
//	it exists using the optimal dedicated routing resources.
//	AND
//	A DCM may only drive one of buffer of an exclusive site pair:
//	Top:
//	  (BUFGMUX7P, BUFGMUX3P)
//	  (BUFGMUX6S, BUFGMUX2S)
//	  (BUFGMUX5P, BUFGMUX1P)
//	  (BUFGMUX4S, BUFGMUX0S)
//	Bottom:
//	  (BUFGMUX7S, BUFGMUX3S)
//	  (BUFGMUX6P, BUFGMUX2P)
//	  (BUFGMUX5S, BUFGMUX1S)
//	  (BUFGMUX4P, BUFGMUX0P)
//------------------------------------------------------------------------------------------------------------------
// Global clock input buffers
//------------------------------------------------------------------------------------------------------------------
	IBUFG uibufg_0p (.I(alct_rxclock ), .O(alct_rxclock_ibufg ));	// synthesis attribute LOC of uibufg0p is "AK17";
	IBUFG uibufg_1p (.I(alct_rxclockd), .O(alct_rxclockd_ibufg));	// synthesis attribute LOC of uibufg1p is "H17"	
	IBUFG uibufg_2p (.I(dcc_clock    ), .O(dcc_clock_ibufg    ));	// synthesis attribute LOC of uibufg2p is "AG17"
	IBUFG uibufg_3p (.I(mpc_clock    ), .O(mpc_clock_ibufg    ));	// synthesis attribute LOC of uibufg3p is "E17"
	IBUFG uibufg_4p (.I(tmb_clock0   ), .O(tmb_clock0_ibufg   ));	// synthesis attribute LOC of uibufg4p is "AF18"
	IBUFG uibufg_5p (.I(tmb_clock0d  ), .O(tmb_clock0d_ibufg  ));	// synthesis attribute LOC of uibufg5p is "E19"
	IBUFG uibufg_6p (.I(tmb_clock1   ), .O(tmb_clock1_ibufg   ));	// synthesis attribute LOC of uibufg6p is "AK19"
//	IBUFG uibufg_7p (.I(rpc_sig      ), .O(rpc_sig_ibufg      ));	// synthesis attribute LOC of uibufg7p is "K18"

//------------------------------------------------------------------------------------------------------------------
// Main TMB DLL global clock output buffers
//------------------------------------------------------------------------------------------------------------------
// Phaser DLL feedback and fanout buffers: FPGA bottom edge
	BUFG ubufg_tmb_1x      (.I(clock_dcm           ),.O(clock             ));	// synthesis attribute LOC of ubufg_tmb_1x       is "BUFGMUX0P"
	BUFG ubufg_tmb_vme     (.I(clock_vme_dcm       ),.O(clock_vme         ));	// synthesis attribute LOC of ubufg_tmb_vme      is "BUFGMUX1S"
	BUFG ubufg_tmb_2x      (.I(clock_2x_dcm        ),.O(clock_2x          ));	// synthesis attribute LOC of ubufg_tmb_2x       is "BUFGMUX2P"
	BUFG ubufg_alct_rxd_fb (.I(clock_alct_rxd_clk0 ),.O(clock_alct_rxd_fb ));	// synthesis attribute LOC of ubufg_alct_rxd_fb  is "BUFGMUX6P"
	BUFG ubufg_alct_txd_fb (.I(clock_alct_txd_clk0 ),.O(clock_alct_txd_fb ));	// synthesis attribute LOC of ubufg_alct_txd_fb  is "BUFGMUX7S"
	
// Phaser DLL feedback and fanout buffers: FPGA top edge
	BUFG ubufg_cfeb0_rxd_fb(.I(clock_cfeb0_rxd_clk0),.O(clock_cfeb0_rxd_fb));	// synthesis attribute LOC of ubufg_cfeb0_rxd_fb is "BUFGMUX3P"
	BUFG ubufg_cfeb1_rxd_fb(.I(clock_cfeb1_rxd_clk0),.O(clock_cfeb1_rxd_fb));	// synthesis attribute LOC of ubufg_cfeb1_rxd_fb is "BUFGMUX4S"
	BUFG ubufg_cfeb2_rxd_fb(.I(clock_cfeb2_rxd_clk0),.O(clock_cfeb2_rxd_fb));	// synthesis attribute LOC of ubufg_cfeb2_rxd_fb is "BUFGMUX5P"
	BUFG ubufg_cfeb3_rxd_fb(.I(clock_cfeb3_rxd_clk0),.O(clock_cfeb3_rxd_fb));	// synthesis attribute LOC of ubufg_cfeb3_rxd_fb is "BUFGMUX6S"
	BUFG ubufg_cfeb4_rxd_fb(.I(clock_cfeb4_rxd_clk0),.O(clock_cfeb4_rxd_fb));	// synthesis attribute LOC of ubufg_cfeb4_rxd_fb is "BUFGMUX7P"
/*
// DCM locations bottom edge
	// synthesis attribute LOC of udcm_tmb       is "DCM_X4Y0"
	// synthesis attribute LOC of udcm_alct_txd  is "DCM_X0Y0"
	// synthesis attribute LOC of udcm_alct_rxd  is "DCM_X1Y0"
	// synthesis attribute LOC of udcm_cfeb0_rxd is "DCM_X2Y0"
	// synthesis attribute LOC of udcm_cfeb1_rxd is "DCM_X3Y0"

// DCM locations top edge
	// synthesis attribute LOC of udcm_cfeb2_rxd is "DCM_X0Y1"
	// synthesis attribute LOC of udcm_cfeb3_rxd is "DCM_X1Y1"
	// synthesis attribute LOC of udcm_cfeb4_rxd is "DCM_X3Y1"
*/
// DCM locations bottom edge
	// synthesis attribute LOC of udcm_alct_txd  is "DCM_X0Y0"
	// synthesis attribute LOC of udcm_alct_rxd  is "DCM_X1Y0"
	// synthesis attribute LOC of udcm_tmb       is "DCM_X2Y0"

// DCM locations top edge
	// synthesis attribute LOC of udcm_cfeb4_rxd is "DCM_X0Y1"
	// synthesis attribute LOC of udcm_cfeb3_rxd is "DCM_X1Y1"
	// synthesis attribute LOC of udcm_cfeb2_rxd is "DCM_X3Y1"
	// synthesis attribute LOC of udcm_cfeb1_rxd is "DCM_X4Y1"
	// synthesis attribute LOC of udcm_cfeb0_rxd is "DCM_X5Y1"

//------------------------------------------------------------------------------------------------------------------
// Main TMB DLL generates clocks at 1x=40MHz, 2x=80MHz, 4x=160MHz
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 			// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKIN_PERIOD		(25.0),			// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("NONE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("2X"),			// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),			// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("TRUE"))		// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_tmb (
	.CLKIN		(tmb_clock0_ibufg),		// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_2x),				// In	DCM clock feedback
	.RST		(dcm_reset),			// In	DCM asynchronous reset
	.PSCLK		(1'b0),					// In	Dynamic phase adjust clock
	.PSEN		(1'b0),					// In	Dynamic phase adjust enable
	.PSINCDEC	(1'b0),					// In	Dynamic phase adjust increment/decrement
	.PSDONE		(),						// Out	Dynamic phase adjust done
	.CLK0		(clock_dcm),			// Out	0   degree DCM CLK
	.CLK90		(clock_dcm_90),			// Out	90 degree DCM CLK
	.CLK180		(),						// Out	180 degree DCM CLK
	.CLK270		(),						// Out	270 degree DCM CLK
	.CLK2X		(clock_2x_dcm),			// Out	2X DCM CLK
	.CLK2X180	(),						// Out	2X, 180 degree DCM CLK
	.CLKDV		(clock_vme_dcm),		// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(),						// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),						// Out	180 degree CLK synthesis
	.LOCKED		(lock_tmb_clock0),		// Out	DCM LOCK status
	.STATUS		());					// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// Logic Accessible Clock copy of 40MHz main clock, synchronized to clock_2x global net
//------------------------------------------------------------------------------------------------------------------
	FDRSE #(.INIT(1'b0)) ulac (
	.Q	(clock_lac),					// Out	Data
	.C	(clock_2x),						// In	Clock
	.CE	(lock_tmb_clock0),				// In	Clock enable
	.D	(!clock_dcm_90),				// In	Data
	.R	(1'b0),							// In	Synchronous reset
	.S	(1'b0));						// In	Synchronous set

//------------------------------------------------------------------------------------------------------------------
// ALCT_rxd DLL phase shifts rx data from alct, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 			// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),			// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),			// Can be any integer from 2 to 32
 	.CLKIN_PERIOD		(25.0),			// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),	// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),			// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),			// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))		// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_alct_rxd (
	.CLKIN		(clock),				// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_alct_rxd_fb),	// In	DCM clock feedback
	.RST		(reset_alct_rxd),		// In	DCM asynchronous reset
	.PSCLK		(clock),				// In	Dynamic phase adjust clock
	.PSEN		(psen_alct_rxd),		// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_alct_rxd),	// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_alct_rxd),		// Out	Dynamic phase adjust done
	.CLK0		(clock_alct_rxd_clk0),	// Out	0   degree DCM CLK
	.CLK90		(clock_alct_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_alct_rxd_clk180),// Out	180 degree DCM CLK
	.CLK270		(clock_alct_rxd_clk270),// Out	270 degree DCM CLK
	.CLK2X		(),						// Out	2X DCM CLK
	.CLK2X180	(),						// Out	2X, 180 degree DCM CLK
	.CLKDV		(),						// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_alct_rxd_4x),	// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),						// Out	180 degree CLK synthesis
	.LOCKED		(lock_alct_rxd),		// Out	DCM LOCK status
	.STATUS		());					// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// ALCT_txd DLL phase shifts tx data to alct, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 			// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),			// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),			// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),			// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),	// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),			// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),			// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))		// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_alct_txd (
	.CLKIN		(clock),				// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_alct_txd_fb),	// In	DCM clock feedback
	.RST		(reset_alct_txd),		// In	DCM asynchronous reset
	.PSCLK		(clock),				// In	Dynamic phase adjust clock
	.PSEN		(psen_alct_txd),		// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_alct_txd),	// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_alct_txd),		// Out	Dynamic phase adjust done
	.CLK0		(clock_alct_txd_clk0),	// Out	0   degree DCM CLK
	.CLK90		(clock_alct_txd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_alct_txd_clk180),// Out	180 degree DCM CLK
	.CLK270		(clock_alct_txd_clk270),// Out	270 degree DCM CLK
	.CLK2X		(),						// Out	2X DCM CLK
	.CLK2X180	(),						// Out	2X, 180 degree DCM CLK
	.CLKDV		(),						// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_alct_txd_4x),	// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),						// Out	180 degree CLK synthesis
	.LOCKED		(lock_alct_txd),		// Out	DCM LOCK status
	.STATUS		());					// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// CFEB0_rxd DLL phase shifts rx data from cfeb, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 				// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),				// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),				// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),				// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),				// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),				// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))			// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_cfeb0_rxd (
	.CLKIN		(clock),					// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_cfeb0_rxd_fb),		// In	DCM clock feedback
	.RST		(reset_cfeb0_rxd),			// In	DCM asynchronous reset
	.PSCLK		(clock),					// In	Dynamic phase adjust clock
	.PSEN		(psen_cfeb0_rxd),			// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_cfeb0_rxd),		// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_cfeb0_rxd),			// Out	Dynamic phase adjust done
	.CLK0		(clock_cfeb0_rxd_clk0),		// Out	0   degree DCM CLK
	.CLK90		(clock_cfeb0_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_cfeb0_rxd_clk180),	// Out	180 degree DCM CLK
	.CLK270		(clock_cfeb0_rxd_clk270),	// Out	270 degree DCM CLK
	.CLK2X		(),							// Out	2X DCM CLK
	.CLK2X180	(),							// Out	2X, 180 degree DCM CLK
	.CLKDV		(),							// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_cfeb0_rxd_4x),		// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),							// Out	180 degree CLK synthesis
	.LOCKED		(lock_cfeb0_rxd),			// Out	DCM LOCK status
	.STATUS		());						// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// CFEB1_rxd DLL phase shifts rx data from cfeb, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 				// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),				// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),				// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),				// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),				// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),				// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))			// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_cfeb1_rxd (
	.CLKIN		(clock),					// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_cfeb1_rxd_fb),		// In	DCM clock feedback
	.RST		(reset_cfeb1_rxd),			// In	DCM asynchronous reset
	.PSCLK		(clock),					// In	Dynamic phase adjust clock
	.PSEN		(psen_cfeb1_rxd),			// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_cfeb1_rxd),		// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_cfeb1_rxd),			// Out	Dynamic phase adjust done
	.CLK0		(clock_cfeb1_rxd_clk0),		// Out	0   degree DCM CLK
	.CLK90		(clock_cfeb1_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_cfeb1_rxd_clk180),	// Out	180 degree DCM CLK
	.CLK270		(clock_cfeb1_rxd_clk270),	// Out	270 degree DCM CLK
	.CLK2X		(),							// Out	2X DCM CLK
	.CLK2X180	(),							// Out	2X, 180 degree DCM CLK
	.CLKDV		(),							// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_cfeb1_rxd_4x),		// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),							// Out	180 degree CLK synthesis
	.LOCKED		(lock_cfeb1_rxd),			// Out	DCM LOCK status
	.STATUS		());						// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// CFEB2_rxd DLL phase shifts rx data from cfeb, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 				// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),				// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),				// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),				// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),				// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),				// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))			// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_cfeb2_rxd (
	.CLKIN		(clock),					// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_cfeb2_rxd_fb),		// In	DCM clock feedback
	.RST		(reset_cfeb2_rxd),			// In	DCM asynchronous reset
	.PSCLK		(clock),					// In	Dynamic phase adjust clock
	.PSEN		(psen_cfeb2_rxd),			// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_cfeb2_rxd),		// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_cfeb2_rxd),			// Out	Dynamic phase adjust done
	.CLK0		(clock_cfeb2_rxd_clk0),		// Out	0   degree DCM CLK
	.CLK90		(clock_cfeb2_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_cfeb2_rxd_clk180),	// Out	180 degree DCM CLK
	.CLK270		(clock_cfeb2_rxd_clk270),	// Out	270 degree DCM CLK
	.CLK2X		(),							// Out	2X DCM CLK
	.CLK2X180	(),							// Out	2X, 180 degree DCM CLK
	.CLKDV		(),							// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_cfeb2_rxd_4x),		// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),							// Out	180 degree CLK synthesis
	.LOCKED		(lock_cfeb2_rxd),			// Out	DCM LOCK status
	.STATUS		());						// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// CFEB3_rxd DLL phase shifts rx data from cfeb, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 				// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),				// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),				// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),				// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),				// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),				// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))			// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_cfeb3_rxd (
	.CLKIN		(clock),					// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_cfeb3_rxd_fb),		// In	DCM clock feedback
	.RST		(reset_cfeb3_rxd),			// In	DCM asynchronous reset
	.PSCLK		(clock),					// In	Dynamic phase adjust clock
	.PSEN		(psen_cfeb3_rxd),			// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_cfeb3_rxd),		// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_cfeb3_rxd),			// Out	Dynamic phase adjust done
	.CLK0		(clock_cfeb3_rxd_clk0),		// Out	0   degree DCM CLK
	.CLK90		(clock_cfeb3_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_cfeb3_rxd_clk180),	// Out	180 degree DCM CLK
	.CLK270		(clock_cfeb3_rxd_clk270),	// Out	270 degree DCM CLK
	.CLK2X		(),							// Out	2X DCM CLK
	.CLK2X180	(),							// Out	2X, 180 degree DCM CLK
	.CLKDV		(),							// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_cfeb3_rxd_4x),		// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),							// Out	180 degree CLK synthesis
	.LOCKED		(lock_cfeb3_rxd),			// Out	DCM LOCK status
	.STATUS		());						// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// CFEB4_rxd DLL phase shifts rx data from cfeb, generates clocks at 1x=40MHz, and 4x
//------------------------------------------------------------------------------------------------------------------
	DCM # (
	.CLKDV_DIVIDE		(4.0), 				// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE		(1),				// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY		(4),				// Can be any integer from 2 to 32
	.CLKIN_PERIOD		(25.0),				// Specify period of input clock in ns
	.CLKOUT_PHASE_SHIFT	("VARIABLE"),		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK		("1X"),				// Specify clock feedback of NONE, 1X or 2X
	.PHASE_SHIFT		(0),				// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT		("FALSE"))			// Delay configuration DONE until DCM LOCK, TRUE/FALSE

	udcm_cfeb4_rxd (
	.CLKIN		(clock),					// In	Clock input (from IBUFG, BUFG or DCM)
	.CLKFB		(clock_cfeb4_rxd_fb),		// In	DCM clock feedback
	.RST		(reset_cfeb4_rxd),			// In	DCM asynchronous reset
	.PSCLK		(clock),					// In	Dynamic phase adjust clock
	.PSEN		(psen_cfeb4_rxd),			// In	Dynamic phase adjust enable
	.PSINCDEC	(psincdec_cfeb4_rxd),		// In	Dynamic phase adjust increment/decrement
	.PSDONE		(psdone_cfeb4_rxd),			// Out	Dynamic phase adjust done
	.CLK0		(clock_cfeb4_rxd_clk0),		// Out	0   degree DCM CLK
	.CLK90		(clock_cfeb4_rxd_clk90),	// Out	90 degree DCM CLK
	.CLK180		(clock_cfeb4_rxd_clk180),	// Out	180 degree DCM CLK
	.CLK270		(clock_cfeb4_rxd_clk270),	// Out	270 degree DCM CLK
	.CLK2X		(),							// Out	2X DCM CLK
	.CLK2X180	(),							// Out	2X, 180 degree DCM CLK
	.CLKDV		(),							// Out	Divided DCM CLK   (CLKDV_DIVIDE)
	.CLKFX		(clock_cfeb4_rxd_4x),		// Out	DCM CLK synthesis (M/D)
	.CLKFX180	(),							// Out	180 degree CLK synthesis
	.LOCKED		(lock_cfeb4_rxd),			// Out	DCM LOCK status
	.STATUS		());						// Out	8-bit DCM status [0]=phase shift overflow,[1]=clkin stopped,[2]=clkfx stopped

//------------------------------------------------------------------------------------------------------------------
// Generate local copies of phase shift selects in 40MHz time domain
//------------------------------------------------------------------------------------------------------------------
	reg hcycle_alct_rxd_ff  = 0,	hcycle_alct_rxd_gated  = 0;
	reg hcycle_alct_txd_ff  = 0,	hcycle_alct_txd_gated  = 0;
	reg hcycle_cfeb0_rxd_ff = 0,	hcycle_cfeb0_rxd_gated = 0;
	reg hcycle_cfeb1_rxd_ff = 0,	hcycle_cfeb1_rxd_gated = 0;
	reg hcycle_cfeb2_rxd_ff = 0,	hcycle_cfeb2_rxd_gated = 0;
	reg hcycle_cfeb3_rxd_ff = 0,	hcycle_cfeb3_rxd_gated = 0;
	reg hcycle_cfeb4_rxd_ff = 0,	hcycle_cfeb4_rxd_gated = 0;

	reg qcycle_alct_rxd_ff  = 0,	qcycle_alct_rxd_gated  = 0;
	reg qcycle_alct_txd_ff  = 0,	qcycle_alct_txd_gated  = 0;
	reg qcycle_cfeb0_rxd_ff = 0,	qcycle_cfeb0_rxd_gated = 0;
	reg qcycle_cfeb1_rxd_ff = 0,	qcycle_cfeb1_rxd_gated = 0;
	reg qcycle_cfeb2_rxd_ff = 0,	qcycle_cfeb2_rxd_gated = 0;
	reg qcycle_cfeb3_rxd_ff = 0,	qcycle_cfeb3_rxd_gated = 0;
	reg qcycle_cfeb4_rxd_ff = 0,	qcycle_cfeb4_rxd_gated = 0;

// Update quadrant select latches when phasers fire
	wire update_quad_alct_rxd;
	wire update_quad_alct_txd;
	wire update_quad_cfeb0_rxd;
	wire update_quad_cfeb1_rxd;
	wire update_quad_cfeb2_rxd;
	wire update_quad_cfeb3_rxd;
	wire update_quad_cfeb4_rxd;

	always @(posedge clock) begin
	if (update_quad_alct_rxd) begin
	hcycle_alct_rxd_gated  <= hcycle_alct_rxd;
	qcycle_alct_rxd_gated  <= qcycle_alct_rxd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_alct_txd) begin
	hcycle_alct_txd_gated  <= hcycle_alct_txd;
	qcycle_alct_txd_gated  <= qcycle_alct_txd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_cfeb0_rxd) begin
	hcycle_cfeb0_rxd_gated <= hcycle_cfeb0_rxd;
	qcycle_cfeb0_rxd_gated <= qcycle_cfeb0_rxd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_cfeb1_rxd) begin
	hcycle_cfeb1_rxd_gated <= hcycle_cfeb1_rxd;
	qcycle_cfeb1_rxd_gated <= qcycle_cfeb1_rxd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_cfeb2_rxd) begin
	hcycle_cfeb2_rxd_gated <= hcycle_cfeb2_rxd;
	qcycle_cfeb2_rxd_gated <= qcycle_cfeb2_rxd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_cfeb3_rxd) begin
	hcycle_cfeb3_rxd_gated <= hcycle_cfeb3_rxd;
	qcycle_cfeb3_rxd_gated <= qcycle_cfeb3_rxd;
	end
	end

	always @(posedge clock) begin
	if (update_quad_cfeb4_rxd) begin
	hcycle_cfeb4_rxd_gated <= hcycle_cfeb4_rxd;
	qcycle_cfeb4_rxd_gated <= qcycle_cfeb4_rxd;
	end
	end

// Local copy of quadrant selects pushed into clock_mux slices
	always @(posedge clock) begin
	hcycle_alct_rxd_ff  <= hcycle_alct_rxd_gated;
	hcycle_alct_txd_ff  <= hcycle_alct_txd_gated;
	hcycle_cfeb0_rxd_ff <= hcycle_cfeb0_rxd_gated;
	hcycle_cfeb1_rxd_ff <= hcycle_cfeb1_rxd_gated;
	hcycle_cfeb2_rxd_ff <= hcycle_cfeb2_rxd_gated;
	hcycle_cfeb3_rxd_ff <= hcycle_cfeb3_rxd_gated;
	hcycle_cfeb4_rxd_ff <= hcycle_cfeb4_rxd_gated;

	qcycle_alct_rxd_ff  <= qcycle_alct_rxd_gated;
	qcycle_alct_txd_ff  <= qcycle_alct_txd_gated;
	qcycle_cfeb0_rxd_ff <= qcycle_cfeb0_rxd_gated;
	qcycle_cfeb1_rxd_ff <= qcycle_cfeb1_rxd_gated;
	qcycle_cfeb2_rxd_ff <= qcycle_cfeb2_rxd_gated;
	qcycle_cfeb3_rxd_ff <= qcycle_cfeb3_rxd_gated;
	qcycle_cfeb4_rxd_ff <= qcycle_cfeb4_rxd_gated;
	end

//------------------------------------------------------------------------------------------------------------------
// Programmable 1/4, 1/2, 3/4 cycle phase shifts, location constraints are in ucf
//------------------------------------------------------------------------------------------------------------------
	clock_mux ualctrxdmux (
	.clk4x	(clock_alct_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_alct_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_alct_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_alct_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_alct_rxd_clk90),		// In	Clock 090 degrees
	.clk180	(clock_alct_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_alct_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_alct_rxd));			// Out	Quadrant shifted clock

// ALCT_txd mux
	clock_mux ualcttxdmux (
	.clk4x	(clock_alct_txd_4x),		// In	4x clock
	.hcycle	(hcycle_alct_txd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_alct_txd_ff),		// In	Quarter cycle select
	.clk0	(clock_alct_txd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_alct_txd_clk90),		// In	Clock 090 degrees
	.clk180	(clock_alct_txd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_alct_txd_clk270),	// In	Clock 270 degrees
	.clk	(clock_alct_txd));			// Out	Quadrant shifted clock

// CFEB0_rxd mux
	clock_mux ucfeb0mux (
	.clk4x	(clock_cfeb0_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_cfeb0_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_cfeb0_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_cfeb0_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_cfeb0_rxd_clk90),	// In	Clock 090 degrees
	.clk180	(clock_cfeb0_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_cfeb0_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_cfeb0_rxd));			// Out	Quadrant shifted clock

// CFEB1_rxd mux
	clock_mux ucfeb1mux (
	.clk4x	(clock_cfeb1_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_cfeb1_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_cfeb1_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_cfeb1_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_cfeb1_rxd_clk90),	// In	Clock 090 degrees
	.clk180	(clock_cfeb1_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_cfeb1_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_cfeb1_rxd));			// Out	Quadrant shifted clock

// CFEB2_rxd mux
	clock_mux ucfeb2mux (
	.clk4x	(clock_cfeb2_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_cfeb2_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_cfeb2_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_cfeb2_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_cfeb2_rxd_clk90),	// In	Clock 090 degrees
	.clk180	(clock_cfeb2_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_cfeb2_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_cfeb2_rxd));			// Out	Quadrant shifted clock

// CFEB3_rxd mux
	clock_mux ucfeb3mux (
	.clk4x	(clock_cfeb3_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_cfeb3_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_cfeb3_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_cfeb3_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_cfeb3_rxd_clk90),	// In	Clock 090 degrees
	.clk180	(clock_cfeb3_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_cfeb3_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_cfeb3_rxd));			// Out	Quadrant shifted clock

// CFEB4_rxd mux
	clock_mux ucfeb4mux (
	.clk4x	(clock_cfeb4_rxd_4x),		// In	4x clock
	.hcycle	(hcycle_cfeb4_rxd_ff),		// In	Half    cycle select
	.qcycle	(qcycle_cfeb4_rxd_ff),		// In	Quarter cycle select
	.clk0	(clock_cfeb4_rxd_clk0),		// In	Clock 000 degrees
	.clk90	(clock_cfeb4_rxd_clk90),	// In	Clock 090 degrees
	.clk180	(clock_cfeb4_rxd_clk180),	// In	Clock 180 degrees
	.clk270	(clock_cfeb4_rxd_clk270),	// In	Clock 270 degrees
	.clk	(clock_cfeb4_rxd));			// Out	Quadrant shifted clock

//------------------------------------------------------------------------------------------------------------------
// Digital phase shifter state machines
//------------------------------------------------------------------------------------------------------------------
// ALCT_rxd
	phaser uphaser_alct_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_alct_rxd),			// In	Lock state for this DCM
	.psen			(psen_alct_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_alct_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_alct_rxd),			// In	Dps done
	.fire			(fire_alct_rxd),			// In	VME Set new phase
	.reset			(reset_alct_rxd),			// In	Reset current phase
	.phase			(phase_alct_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_alct_rxd),		// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_alct_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_alct_rxd));	// Out	Update quadrant select FFs

// ALCT_txd
	phaser uphaser_alct_txd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_alct_txd),			// In	Lock state for this DCM
	.psen			(psen_alct_txd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_alct_txd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_alct_txd),			// In	Dps done
	.fire			(fire_alct_txd),			// In	Set new phase
	.reset			(reset_alct_txd),			// In	Reset current phase
	.phase			(phase_alct_txd[5:0]),		// In	Phase to set, 0-255
	.busy			(phaser_busy_alct_txd),		// Out	Phase shifter busy
	.dps_sm_vec		(phaser_sm_alct_txd[2:0]),	// Out	Phase shifter machine state
	.update_quad	(update_quad_alct_txd));	// Out	Update quadrant select FFs

// CFEB0_rxd
	phaser uphaser_cfeb0_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_cfeb0_rxd),			// In	Lock state for this DCM
	.psen			(psen_cfeb0_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_cfeb0_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_cfeb0_rxd),			// In	Dps done
	.fire			(fire_cfeb0_rxd),			// In	VME Set new phase
	.reset			(reset_cfeb0_rxd),			// In	Reset current phase
	.phase			(phase_cfeb0_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_cfeb0_rxd),	// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_cfeb0_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_cfeb0_rxd));	// Out	Update quadrant select FFs

// CFEB1_rxd
	phaser uphaser_cfeb1_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_cfeb1_rxd),			// In	Lock state for this DCM
	.psen			(psen_cfeb1_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_cfeb1_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_cfeb1_rxd),			// In	Dps done
	.fire			(fire_cfeb1_rxd),			// In	VME Set new phase
	.reset			(reset_cfeb1_rxd),			// In	Reset current phase
	.phase			(phase_cfeb1_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_cfeb1_rxd),	// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_cfeb1_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_cfeb1_rxd));	// Out	Update quadrant select FFs

// CFEB2_rxd
	phaser uphaser_cfeb2_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_cfeb2_rxd),			// In	Lock state for this DCM
	.psen			(psen_cfeb2_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_cfeb2_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_cfeb2_rxd),			// In	Dps done
	.fire			(fire_cfeb2_rxd),			// In	VME Set new phase
	.reset			(reset_cfeb2_rxd),			// In	Reset current phase
	.phase			(phase_cfeb2_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_cfeb2_rxd),	// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_cfeb2_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_cfeb2_rxd));	// Out	Update quadrant select FFs

// CFEB3_rxd
	phaser uphaser_cfeb3_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_cfeb3_rxd),			// In	Lock state for this DCM
	.psen			(psen_cfeb3_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_cfeb3_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_cfeb3_rxd),			// In	Dps done
	.fire			(fire_cfeb3_rxd),			// In	VME Set new phase
	.reset			(reset_cfeb3_rxd),			// In	Reset current phase
	.phase			(phase_cfeb3_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_cfeb3_rxd),	// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_cfeb3_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_cfeb3_rxd));	// Out	Update quadrant select FFs

// CFEB4_rxd
	phaser uphaser_cfeb4_rxd (
	.clock			(clock),					// In	40MHz global TMB clock 1x
	.global_reset	(global_reset),				// In	Global reset, asserted until main DLL locks
	.lock_tmb		(lock_tmb_clock0),			// In	Lock state for TMB main clock DLL
	.lock_dcm		(lock_cfeb4_rxd),			// In	Lock state for this DCM
	.psen			(psen_cfeb4_rxd),			// Out	Dps phase shift enable
	.psincdec		(psincdec_cfeb4_rxd),		// Out	Dps phase increment/decrement
	.psdone			(psdone_cfeb4_rxd),			// In	Dps done
	.fire			(fire_cfeb4_rxd),			// In	VME Set new phase
	.reset			(reset_cfeb4_rxd),			// In	Reset current phase
	.phase			(phase_cfeb4_rxd[5:0]),		// In	VME Phase to set, 0-255
	.busy			(phaser_busy_cfeb4_rxd),	// Out	VME Phase shifter busy
	.dps_sm_vec		(phaser_sm_cfeb4_rxd[2:0]),	// Out	VME Phase shifter machine state
	.update_quad	(update_quad_cfeb4_rxd));	// Out	Update quadrant select FFs

//------------------------------------------------------------------------------------------------------------------
// Global reset for fpga-wide state machines, asserted until main DLL locks
//------------------------------------------------------------------------------------------------------------------
	reg global_reset    = 1;
	reg startup_done	= 0;

	wire first_lock = (lock_tmb_clock0 || startup_done);

	always @(posedge clock) begin
	startup_done	<=	first_lock;												// Latches  on 1st dll lock
	global_reset	<= !first_lock || (!lock_tmb_clock0 && global_reset_en);	// Re-fires on lock lost
	end

	assign clock_lock_lost_err = (!global_reset && !lock_tmb_clock0);			// Latches  on lock lost in sync module

//------------------------------------------------------------------------------------------------------------------
// Pseudo-locked status for unused clock inputs, DDR FFs q0+q1 should add to 1 if clock is running
//------------------------------------------------------------------------------------------------------------------
	reg	[1:0]	tmb_clock0d_q	= 0;
	reg	[1:0]	alct_rxclockd_q	= 0;
	reg	[1:0]	mpc_clock_q		= 0;
	reg	[1:0]	dcc_clock_q		= 0;
	reg	[1:0]	rpc_rxalt1_q	= 0;
	reg [1:0]	tmb_clock1_q	= 0;
	reg [1:0]	alct_rxclock_q	= 0;

	always @(posedge clock)	begin
	tmb_clock0d_q[0]	<= tmb_clock0d_ibufg && lock_tmb_clock0;	// Force ibuf insertion
	alct_rxclockd_q[0]	<= alct_rxclockd_ibufg;
	mpc_clock_q[0]		<= mpc_clock_ibufg;
	dcc_clock_q[0]		<= dcc_clock_ibufg;
	rpc_rxalt1_q[0]		<= rpc_sig;
	tmb_clock1_q[0]		<= tmb_clock1_ibufg;
	alct_rxclock_q[0]	<= alct_rxclock_ibufg;
	end

	always @(negedge clock) begin
	tmb_clock0d_q[1]	<= tmb_clock0d_ibufg && lock_tmb_clock0;	// Force ibuf insertion
	alct_rxclockd_q[1]	<= alct_rxclockd_ibufg;
	mpc_clock_q[1]		<= mpc_clock_ibufg;
	dcc_clock_q[1]		<= dcc_clock_ibufg;
	rpc_rxalt1_q[1]		<= rpc_sig;
	tmb_clock1_q[1]		<= tmb_clock1_ibufg;
	alct_rxclock_q[1]	<= alct_rxclock_ibufg;
	end

	assign lock_tmb_clock0d		= ^ tmb_clock0d_q[1:0];
	assign lock_alct_rxclockd	= ^ alct_rxclockd_q[1:0];
	assign lock_mpc_clock		= ^ mpc_clock_q[1:0];
	assign lock_dcc_clock		= ^ dcc_clock_q[1:0];
	assign lock_rpc_rxalt1		= ^ rpc_rxalt1_q[1:0];
	assign lock_tmb_clock1		= ^ tmb_clock1_q[1:0];
	assign lock_alct_rxclock	= ^ alct_rxclock_q[1:0];

//------------------------------------------------------------------------------------------------------------------
	endmodule
//------------------------------------------------------------------------------------------------------------------
