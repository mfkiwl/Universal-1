/*
	6 RZ (ARINC429) lines input into 16w RAM
	main clk <= clk_400kHz
*/
/*		<==========

wire [4:0]  rd_arinc1,
				rd_arinc2,
				rd_arinc3,
				rd_arinc4,
				rd_arinc5,
				rd_arinc6;
 
wire [15:0]	arinc_1_outp,
				arinc_2_outp,
				arinc_3_outp,
				arinc_4_outp,
				arinc_5_outp,
				arinc_6_outp; 

RZ_LINE_TOP
RZ_LINE_TOP_Unit
(
	 .clock		(clk_400kHz),
	 .inp_clk	(inp_clk),
	 .reset		(reset),
	 
	 .line_A1	(line_A1),
	 .line_B1	(line_B1),
	 .line_A2	(line_A2),
	 .line_B2	(line_B2),
	 .line_A3	(line_A3),
	 .line_B3	(line_B3),
	 .line_A4	(line_A4),
	 .line_B4	(line_B4),
	 .line_A5	(line_A5),
	 .line_B5	(line_B5),
	 .line_A6	(line_A6),
	 .line_B6	(line_B6),
	 
	 .rd_arinc1		(rd_arinc1),
	 .rd_arinc2		(rd_arinc2),
	 .rd_arinc3		(rd_arinc3),
	 .rd_arinc4		(rd_arinc4),
	 .rd_arinc5		(rd_arinc5),
	 .rd_arinc6		(rd_arinc6),
	
	 .arinc_1_outp	(arinc_1_outp),
	 .arinc_2_outp	(arinc_2_outp),
	 .arinc_3_outp	(arinc_3_outp),
	 .arinc_4_outp	(arinc_4_outp),
	 .arinc_5_outp	(arinc_5_outp),
	 .arinc_6_outp	(arinc_6_outp)
);

*/


module RZ_LINE_TOP
(
 input  wire 	clock,
					inp_clk,
					reset,
					
					line_A1, line_B1,
					line_A2, line_B2,
					line_A3, line_B3,
					line_A4, line_B4,
					line_A5, line_B5,
					line_A6, line_B6,		

input wire [4:0]  rd_arinc1,
						rd_arinc2,
						rd_arinc3,
						rd_arinc4,
						rd_arinc5,
						rd_arinc6,
 
output wire [15:0]	arinc_1_outp,
							arinc_2_outp,
							arinc_3_outp,
							arinc_4_outp,
							arinc_5_outp,
							arinc_6_outp
);


 

	
alt_429
ARINC_429_1
(
	 .clock			(clock),
	 .reset			(reset),
	 .inp_clk		(inp_clk),
	 .line_A			(line_A1),
	 .line_B			(line_B1),
	 .rdaddress		(rd_arinc1),
	 .q				(arinc_1_outp)
);


alt_429
ARINC_429_2(
	 .clock		(clock),
	 .reset		(reset),
	 .inp_clk	(inp_clk),
	 .line_A		(line_A2),
	 .line_B		(line_B2),
	 .rdaddress	(rd_arinc2),
	 .q			(arinc_2_outp)
);


alt_429
ARINC_429_3(
	 .clock		(clock),
	 .reset		(reset),
	 .inp_clk	(inp_clk),
	 .line_A		(line_A3),
	 .line_B		(line_B3),
	 .rdaddress	(rd_arinc3),
	 .q			(arinc_3_outp)
);


alt_429
ARINC_429_4(
	 .clock		(clock),
	 .reset		(reset),
	 .inp_clk	(inp_clk),
	 .line_A		(line_A4),
	 .line_B		(line_B4),
	 .rdaddress	(rd_arinc4),
	 .q			(arinc_4_outp)
);


alt_429
ARINC_429_5(
	 .clock		(clock),
	 .reset		(reset),
	 .inp_clk	(inp_clk),
	 .line_A		(line_A5),
	 .line_B		(line_B5),
	 .rdaddress	(rd_arinc5),
	 .q			(arinc_5_outp)
);


alt_429
ARINC_429_6(
	 .clock		(clock),
	 .reset		(reset),
	 .inp_clk	(inp_clk),
	 .line_A		(line_A6),
	 .line_B		(line_B6),
	 .rdaddress	(rd_arinc6),
	 .q			(arinc_6_outp)
);
//--------------------------------------------------------------------------------------------------------//

endmodule