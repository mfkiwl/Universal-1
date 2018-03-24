
//`include "defines.vh"

parameter serial_number = "RP24";

`define CFDR /* CC_transmit.v */ /* bytes sent to CC 
									if (CFDR) => subframe 2048
									else	  => subframe 2048
								 */
								 
`ifndef	CFDR

	`define RP 
	
	`define AUDIO  	/*  aTOP_ARCTIUM					// USE one phisical channel of SOUND
						Get_All_and_Trans_TOP */ 

	`define RAW_ADC /* ADAU <- sets UARTx to trans all data from ADC*/
	
`else 

	`define LPC			/* Get_All_and_Trans_TOP */  	// USEs modules to trans to LPC
	
	`define USE_SYNC  	/* RTC */						// Sync signal on cross 
	
`endif

