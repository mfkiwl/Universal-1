/*
	TAHO_cnt & IMPULS detector
*/
/*		<==========

wire [15:0] freq1, freq2, imp;

TAHO_IMPULS_TOP
TAHO_IMPULS_TOPUnit
(
	 .clock		(clk_1MHz),
	 .reset		(reset),
	 .msec		(msec),
	 .sec			(sec),
	 
	 .taho1		(taho1),
	 .taho2		(taho2),	 
	 .impuls		(impuls),	
	 
	 .freq1		(freq1),
	 .freq2		(freq2),
	 .imp			(imp)
);
*/


module TAHO_IMPULS_TOP
(
	 clock,		// clk_1MHz
	 reset,
	 msec,
	 sec,
	 
	 taho1,
	 taho2,	 
	 impuls,
	 
	 freq1,
	 freq2,
	 imp
);

input wire 	clock,
				reset,
				sec,
				msec,
				taho1,
				taho2,
				impuls;
 
output wire [15:0] 	freq1,
							freq2,
							imp;


TAHO 
TAHO_Unit1
(
	 .clock		(clock),
	 .reset		(reset),
	 .sec			(sec),	 
	 .taho		(taho1),	 
	 .freq		(freq1)
);

TAHO 
TAHO_Unit2
(
	 .clock		(clock),
	 .reset		(reset),
	 .sec			(sec),	 
	 .taho		(taho2),	 
	 .freq		(freq2)
);


IMPULS 
IMPULS_Unit
(
	 .clock		(clock),
	 .reset		(reset),
	 .msec		(msec),	 
	 .impuls		(impuls),	 
	 .imp			(imp)
);

endmodule