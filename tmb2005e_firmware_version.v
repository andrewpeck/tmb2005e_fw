//---------------------------------------------------------------------------------------------------------------------------------------
//	TMB2005E Global Definitions: Turn off user file associations in Edit/Preferences/ISEGeneral
//---------------------------------------------------------------------------------------------------------------------------------------
// Firmware version global definitions
	`define FIRMWARE_TYPE		04'hC		// C=Normal CLCT/TMB, D=Debug PCB loopback version
	`define VERSION				04'hE		// Version revision number, A=TMB2004 and earlier, E=TMB2005E production
	`define MONTHDAY			16'h0707	// Version date
	`define YEAR				16'h2010	// Version date
	`define FPGAID				16'h4000	// FPGA Type XC2Vnnnn
	`define ISE_VERSION			16'h0823	// ISE Compiler version 8.2i sp3 or 10.1i sp3
	`define MEZCARD				04'hC		// Mezzanine Card: A=V23K, B=V24K prototype, C=V24K production

	`define AUTO_VME			01'h1		// Automatically initialize VME registers from PROM data,   0=do not
	`define AUTO_JTAG			01'h1		// Automatically initialize JTAG chain from PROM data,      0=do not
	`define AUTO_PHASER			01'h1		// Automatically initialize PHASER machines from PROM data, 0=do not
	`define ALCT_MUONIC			01'h1		// Floats ALCT board  in clock-space with independent time-of-flight delay
	`define CFEB_MUONIC			01'h1		// Floats CFEB boards in clock-space with independent time-of-flight delay
	`define CCB_BX0_EMULATOR	01'h0		// Turns on bx0 emulator at power up, must be 0 for all CERN versions
//---------------------------------------------------------------------------------------------------------------------------------------
// Conditional compile flags: Enable only one CSC_TYPE
//---------------------------------------------------------------------------------------------------------------------------------------
//	`define CSC_TYPE_A			04'hA		// Normal   CSC:  Normal chambers facing toward IR
//	`define CSC_TYPE_B			04'hB		// Reversed CSC:  Normal chambers facing away from IR. All  hs = reversed
//	`define CSC_TYPE_C			04'hC		// Normal   ME1B: ME1B   chambers facing toward IR.    ME1B hs =!reversed, ME1A hs = reversed
	`define CSC_TYPE_D			04'hD		// Reversed ME1B: ME1B   chambers facing away from IR. ME1B hs = reversed, ME1A hs =!reversed
//---------------------------------------------------------------------------------------------------------------------------------------
// Revision log
//---------------------------------------------------------------------------------------------------------------------------------------
//	09/05/08 Replace tmb me1a processing to block clcts to mpc
//	09/11/08 Add tmb trig keep strobes to header
//	09/12/08 Bugfix in tmb.v that was blocking LCTs to MPC for CLCTs on CFEB4 in normal CSCs
//	09/16/08 Mod scope to read 8 ram blocks
//	09/17/08 Update scope for programmable number of tbins per channel, default of 4096 overflows tmbs dmb rams
//	09/18/08 Tune scope ram mux timing, add scope_ram_init to set data=adr
//	09/19/08 Change sequencer look-ahead logic for scope read start, remove output mux FF from scope ram to speed it up 1bx
//	09/23/08 Fix scope automode address mux timing
//	09/24/08 Reassign scope channels to skip mod 16 beco DMB allows only 15-bit readout, add me1a discard counters
//	09/25/08 Fix scope automode frame counter to span 640 instead of 512
//	09/29/08 Remove scope clear on buf pop, it clears itself after readout
//	09/30/08 Fix scope automode ram addressing
//	10/22/08 Conform tmb signal names to sequencer output signals
//	10/24/08 Add tmb_trig_write to sequencer
//	10/28/08 Fix eef marker insertion for short-header-only format
//	10/29/08 Mod short header-only mode to turn on if no buffer data is available
//	10/29/08 Mod long header-only mode to blank cfeb and rpc lists
//	11/03/08 Mod long header again
//	11/14/08 Add sync error counter
//	11/15/08 Add data array to queue storage
//	11/16/08 Mod fence queue to store l1a data, rename r_type, add bxn at l1a
//	11/17/08 Add has_hdr to sequencer
//	11/17/08 In cfeb.v and rpc.v invert parity so all 0s data has parity=1
//	11/17/08 In cfeb.v change raw hits ram access to read-first so parity output is always valid
//	11/18/08 In cfeb.v add non-staggered injector pattern for ME1A/B
//	11/18/08 In rpc.v change raw hits ram access to read-first so parity output is always valid
//	11/18/08 Add pulsed output sequencer perr counter
//	11/18/08 Mod perr enable to wait for raw hits rams to write parity to all 2K addresses
//	11/26/08 Mod rpc rams to read_first, add parity err ram map
//	12/01/08 Change cnt_non_me1ab_en default to 0
//	12/02/08 Add l1a look back
//	12/08/08 Mod wr_buf_avail for notmb L1A readouts
//	12/08/08 Add sequencer debug register
//	12/09/08 Fix l1a_lookback vector range in vme.v
//	12/10/08 Change counter enables[34:26] from wr_en_rtmb to wr_push_rtmb to avoid continuous counting in l1a-mode
//	01/12/09 Port from ISE 8.2 sp3 to ISE 10.1i sp2, mod vmesm,jtagsm_new,jtagsm_old,ddd_rat to work in ise 10.1i
//	01/20/09 Add alct cable loopback test logic
//	01/21/09 Add rng comparison latch to alct.v
//	01/22/09 Change to ISE 10.1i sp3
//	01/26/09 Add tx to rx comparison FFs in alct.v to detect transient errors
//	01/27/09 Add expected alct rxdata in sync mode to vme readout
//	01/29/09 Fix alct.v lfsr enable
//	01/30/09 Enable alct transmitter lfsr with alct_sync_tx_random
//	02/05/09 Add received data blanking during alct_sync_mode
//	02/24/09 Add ecc to data received from alct, add 2 ecc error counters
//	03/02/09 Fix sync blanking in alct.v, add ecc to alct trigger data for header, add ecc vme enable
//	03/06/09 Add 1bx to alct trigger path to buffer ecc decoder, add alct tx data ecc encoder+reply counter
//	03/06/09 Add separate cfeb pretrigger counters, add alct ecc reply counter
//	03/06/09 Change alct tx delay default for reference system tests
//	03/06/09 Add separate l1a bxn counter and vme offset
//	03/10/09 Symmetrize alct loopback receive data path delays around ecc ff
//	03/11/09 Add counters for all ecc syndrome cases
//	03/12/09 Add alct bx0 counter, temporarily remove ecc ff stage
//	03/16/09 Add 1bx to alct trigger path to buffer ecc decoding
//	03/20/09 Redesign alct.v x_mux sync stage to improve alct_rx_clock window
//	03/23/09 Add din2nd FF stage to x_mux sync
//	03/24/09 Add buffer ffs before iobs in alct.v
//	03/26/09 Remove mux ffs in alct.v, add 80mhz ff loc constraints for alct tx in ucf
//	03/30/09 Add interstage sync to alct.v and alct_posneg to vme.v
//	03/31/09 Tried 3/4 cycle shift
//	04/02/09 No improvement, so reverted to 1/2-cycle
//	04/06/09 Remove mux ffs in alct.v, replaced by sync-stage FFs in x_mux
//	04/07/09 Put mux ffs back in alct.v, they improve rx tx good spots
//	04/22/09 Port all modules to ISE 10.1i, add SM recovery states
//	04/27/09 Removed 2 brams, 1 from alct.v and 1 from sequencer.v, first full compile in tmb2005e folder
//	04/29/09 Add miniscope to tmb main, connections to parity, sequencer, vme incomplete
//	04/30/09 Add miniscope parity
//	05/01/09 Add miniscope to sequencer, vme
//	05/05/09 Miniscope readout sm bugfix
//	05/06/09 Miniscope start fast lookahead
//	05/08/09 Add rpc pretrig marker, insert 8bx pre-delay for alct loopback randoms
//	05/11/09 Miniscope pointer trimmed, add 1st word tbins option
//	05/11/09 Add data=address test mode to RPC
//	05/11/09 Reduce latency in rpc module, adjust rpc ram pointer to match clct pretrigger
//	05/11/09 Implement rpc raw hits delays
//	05/12/09 Add alct trigger path blanking option if ecc cannot correct an error, add counter for blocked alcts
//	05/12/09 Remove old alct signals seq_status[1:0],seu_status[1:0],reserved_out[3:0],reserved_in[3:0] from VME and alct.v
//	05/14/09 Add bx0=vpf test mode for bx0 alignment tests
//	05/14/09 Change adr 86[13] default to send clct_bx0 to mpc instead of ttc bx0
//	05/15/09 Change adr 86[13] default back to ttc bx0
//	05/22/09 Fix vme_bx0 OR in ccc.v
//	05/27/09 Change to alct receive data muonic timing to float ALCT board in clock-space
//	05/28/09 Add interstage to muonic receiver, add maxdelay and maxskew constraints to alct rx and tx ff paths
//	05/29/09 Relax alct demux maxdelay constraints
//	05/29/09 Add random pipeline fixed pre-delay to adr 104, compensate for 2bx muonic symc
//	06/03/09 Remove alct demux constraints to see if goodspots improves
//	06/05/09 Change synthesis property xilinx specific IOB packing from "auto" to "yes"
//	06/05/09 Remove non-muonic alct rx data option to see if goodspots improves
//	06/05/09 Add dmb_tx_reserved[4:0] for spare tmb-to-dmb signals
//	06/11/09 Switch to digital phase shifter for alct rxd and txd data paths
//	06/12/09 Replace alct txd rxd interstages with lac clock
//	06/15/09 Change digital phase shifter range to -32 to +31, add half cycle shift to alct io units
//	06/16/09 Revert to non digital phase shifter, dps was rejected by poobah
//	06/18/09 Add cfeb muonic and conditional compiles for both aclt and cfeb muonic options
//	06/22/09 Change tof and dmb delay defaults
//	06/25/09 Change to mux logic using 4x clock to span 90 degree phase boundaries
//	06/25/09 Add digital phase shifter for muonic cfebs
//	06/29/09 Remove digital phase shifters for cfebs, certain cfeb IOBs can not have 2 clock domains
//	07/10/09 Return digital phase shifters for cfebs, mod ucf to move 5 IOB DDRs to fabric
//	07/13/09 Bugfix in alct ddr demux attribute
//	07/21/09 Reassign all dcms and gbufs, add gbufs to cfeb digital phase shifter clocks, move clock_vme to non-gbuf
//	07/22/09 Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//	08/03/09 Replace vme interface with pipelined core
//	08/04/09 Replace digital phase shifter multiplexers with a submodule and add ucf location constraints
//	08/05/09 cfeb_rx: Remove iob async clear, add final stage sync clear, push srl delay through final sync stage
//	08/05/09 alct_rx: Remove interstage delay SRL and iob async clear, add final stage sync clear
//	08/05/09 alct_tx: Move timing constraints to ucf, remove async clear, add sync clear to IOB ffs
//	08/06/09 Add ffs to boost phase shifter quadrant selects into 160 mhz time domain
//	08/07/09 Relax phase shifter quadrant select delay constraint
//	08/07/09 Remove cfeb phase shifter global buffers, revert to 10mhz vme clock
//	08/10/09 Cfeb rx ddr: push srl delay back to before final sync stage, was causing pattern finder fail timing
//	08/10/09 Cfeb rx ddr: add ff buffer for delay stage address
//	08/10/09 Add quadrant select ff buffers, swap 1x and vme gbufs
//	08/10/09 Add synthesis attribute period to top level module...then removed it, caused 10%
//	08/11/09 Convert cylon and dsn to 40mhz clock
//	08/11/09 Replace clock_vme with clock in cfeb.v
//	08/12/09 Add filler ffs to clock_mux clb, replace clock_vme in sequencer, rpc, tmb
//	08/13/09 Put posneg back into alct receiver
//	08/14/09 Mod alct receiver ucf, mod posneg for negedge mode
//	08/14/09 Take alct posneg back out, can not pass timing in par
//	08/17/09 Put alct posneg back in, with 2x clock interstage, and new alct rx locs in par
//	08/18/09 Replace alct posneg with 1x clock interstage, 2x failed par again
//	08/19/09 Move pipeline to 4 of 8 in best1of32_busy..made timing worse...so put it back
//	08/19/09 Replace sync clr with aclr in cfeb receiver...no change to timing...so put it back
//	08/19/09 Add synth attribute period to pattern finder, its the 1x and 2x bottleneck...made timing worse..take it out
//	08/20/09 Add register balancing to pattern finder...works...but take it back out
//	08/21/09 Revert to ise 8.2, it gets synthesis 92% full, while 10.1i gets 95% and switches to area optimize
//	08/21/09 Add cfeb transparent posneg
//	08/25/09 Mod clct sm re-trigger in sequencer.v to stay busy only for enabled trigger sources
//	09/03/09 Change phaser delay names and alct,cfeb integer delay names in vme, alct, cfeb modules\
//	09/04/09 Add bx0 mez test points
//	09/08/09 Add digital phase shifter auto start
//	09/09/09 Remove bx0 mez test points to save space, yeah it makes a difference
//	09/11/09 Add quadrant update linked to fire stobe in clock_virtex2.v
//	09/13/09 FF buffer update strobe in phaser.v
//	09/16/09 Add sync err control module
//	09/21/09 New area constraints skirt around phase shifter mux units
//	09/21/09 Restrict bxn offsets to be in the interval 0 < lhc_cycle to prevent non-physical bxns
//	09/21/09 Relocate dcms to shorten clock paths
//	09/23/09 Push ccb ffs into iobs
//	09/28/09 Push dmb ffs into iobs
//	09/28/09 Mod vme.v push startup for step and loopback reg into reg inits
//	09/29/09 Move vme inputs into IOBs
//	09/30/09 Revert vme inputs
//	10/07/09 Fix readout record type in sequencer.v
//	10/14/09 Add error counter for 2-identical alct muons
//	10/15/09 Enable alct error counters by default, ff buffer alct error logic for speed
//	10/15/09 Remove unused bit in uslrdrift in sequencer.v
//	11/16/09 Just a recompile after text edit
//	12/14/09 Add bad cfeb bit detection and associated VME registers
//	12/15/09 Add bad cfeb bit list to header
//	01/06/10 Import tmb2005x mods, change cfeb bad bits enable signal name to block
//	01/07/10 Mod revcode to work for years 2010 and beyond
//	01/08/10 Mod revcode again, it was causing vme_d to f5_mux
//	01/11/10 Move bad bits check downstream of pattern injector
//	01/13/10 Add 1bx high bad cfeb bit detection
//	01/14/10 Move bad bits check to triad_s1 in cfeb.v
//	02/04/10 Reverse type b layers
//	02/10/10 Reverse type b active feb flags
//	02/10/10 Add event clear for clct vme diagnostic registers
//	02/12/10 Blank non-triggering status bits for triggering events
//	02/26/10 Add event clear for alct vme diagnostic registers
//	02/26/10 Revert non-trigging blanking in tmb.v temporarily
//	02/28/10 Fixed non-triggering status bits in tmb.v
//	03/01/10 Changed tmb_allow_clct_ro default to 1
//	03/04/10 Fix clct|alct duplication for case where first clct|alct is dummy in tmb.v
//	03/05/10 Move hot channel + bad bits blocking ahead of raw hits ram, a big mistake, but poobah insists
//	03/07/10 Add cfeb blocked bits to dmb readout
//	03/19/10 Mod busy hs delimiters for me1a me1b cscs to separate cfeb4
//	04/16/10 Fix tmb.v kill_clct logic for type C|D
//	04/27/10 Replace x_library routines with ise 11 versions
//	04/27/10 Add bx0 emulator to ccb.v add ttc_resync clears clock_lock_lost
//	04/28/10 XST crash traced to x_delay srl address FF, removed FFs, it is an xst bug fixed in ise 11.5
//	04/28/10 Add forced sync error for system test
//	04/29/10 Revert x_delay to FF version, it is bigger yet somehow faster, add FF to bx0 emulator
//	05/07/10 Load registers presets at power up instead of on 1st clock
//	05/10/10 Add explict width to address parameter constants in vme.v
//	05/12/10 Mod sequencer, clock, sync modules to fix sync_err always 1, add clock_lock lost to vme 0x120
//	05/13/10 Mod ccb.v to clean up fmm ffs and remove resync from bx0 emulator
//	05/14/10 Turn off bx0 emulator for CERN version
//	06/24/10 Bugfix in tmb.v for multiple clcts in match window
//	06/24/10 Add l1a window priority to read out only one event per l1a
//	06/24/10 New miniscope channel assignments, turn on miniscope by default
//	06/26/10 Reduce miniscope to 14 channels beco unpacker is weak, add stall flag to header
//	06/30/10 Mod injector RAM for alct and l1a bits
//	07/01/10 Add counter for events lost from readout due to L1A window prioritizing
//	07/04/10 Set default l1a_win_pri_en=1
//	07/07/10 Move cfeb injector msbs to l1a lookback register, revert to discrete ren, wen
//---------------------------------------------------------------------------------------------------------------------------------------
//	End TMB2005E Global Definitions
//---------------------------------------------------------------------------------------------------------------------------------------
