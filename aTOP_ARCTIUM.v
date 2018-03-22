module aTOP_ARCTIUM
(
	inp_clk,
	
	CNV,
	SDI,
	CLK,
	SDO,
	
	ADDR,
	ENA,
	
	TX_data,
	TX_data_aud,
	
	gps,
	
	taho1,
	taho2,
	impuls,
	
	LED,
	AUD1,
	
	line_A1, line_B1,
	line_A2, line_B2,
	line_A3, line_B3,
	line_A4, line_B4,
	line_A5, line_B5,
	line_A6, line_B6,	
//	line_A21, line_B21,	line_A31, line_B31,	line_A41, line_B41,	line_A51, line_B51,	line_A61, line_B61,
	
	div,
	mul
);

input  wire inp_clk		/* synthesis altera_chip_pin_lc="@91" */; 
input  wire SDO		/* synthesis altera_chip_pin_lc="@50" */; 

output wire CNV			/* synthesis altera_chip_pin_lc="@51" */; 
output wire CLK			/* synthesis altera_chip_pin_lc="@52" */; 
output wire SDI			/* synthesis altera_chip_pin_lc="@53" */; 

output wire TX_data		/* synthesis altera_chip_pin_lc="@143" */; 	//	LPC & MK
output wire TX_data_aud	/* synthesis altera_chip_pin_lc="@30" */; 	// CC  & MK


input  wire 	gps			/* synthesis altera_chip_pin_lc="@137" */,
					taho1			/* synthesis altera_chip_pin_lc="@31" */,
					taho2			/* synthesis altera_chip_pin_lc="@39" */,
					impuls		/* synthesis altera_chip_pin_lc="@142" */;
		
	 output wire 	LED						/* synthesis altera_chip_pin_lc="@138" */;
	 

	 
	 input  wire 	AUD1						/* synthesis altera_chip_pin_lc="@38" */;			//		<<<<<<<<<<<<<<<<<<<<<<<<<< AUD
	 
	 input  wire 	line_A1						/* synthesis altera_chip_pin_lc="@74" */;		
	 input  wire 	line_B1						/* synthesis altera_chip_pin_lc="@75" */;		
	 
	 input  wire 	line_A2						/* synthesis altera_chip_pin_lc="@76" */;		
	 input  wire 	line_B2						/* synthesis altera_chip_pin_lc="@79" */;		
	 
	 input  wire 	line_A3						/* synthesis altera_chip_pin_lc="@83" */;		
	 input  wire 	line_B3						/* synthesis altera_chip_pin_lc="@85" */;		
	 
	 input  wire 	line_A4						/* synthesis altera_chip_pin_lc="@87" */;		
	 input  wire 	line_B4						/* synthesis altera_chip_pin_lc="@89" */;		
	 
	 input  wire 	line_A5						/* synthesis altera_chip_pin_lc="@98" */;		
	 input  wire 	line_B5						/* synthesis altera_chip_pin_lc="@110" */;		
	 
	 input  wire 	line_A6						/* synthesis altera_chip_pin_lc="@103" */;		
	 input  wire 	line_B6						/* synthesis altera_chip_pin_lc="@105" */;		
//	 
//	 input  wire 	line_A21						/* synthesis altera_chip_pin_lc="@77" */;		
//	 input  wire 	line_A31						/* synthesis altera_chip_pin_lc="@84" */;		
//	 input  wire 	line_A41						/* synthesis altera_chip_pin_lc="@88" */;			 
//	 input  wire 	line_A51						/* synthesis altera_chip_pin_lc="@99" */;		
//	 input  wire 	line_A61						/* synthesis altera_chip_pin_lc="@104" */;		
//	 
//	 input  wire 	line_B21						/* synthesis altera_chip_pin_lc="@80" */;		
//	 input  wire 	line_B31						/* synthesis altera_chip_pin_lc="@86" */;		
//	 input  wire 	line_B41						/* synthesis altera_chip_pin_lc="@90" */;			
//	 input  wire 	line_B51						/* synthesis altera_chip_pin_lc="@111" */;		
//	 input  wire 	line_B61						/* synthesis altera_chip_pin_lc="@106" */;		
	 

output wire [3:0] ADDR; 	
output wire [3:0] ENA; 

output wire div			/* synthesis altera_chip_pin_lc="@73" */;	assign div = 1'b1;
output wire mul			/* synthesis altera_chip_pin_lc="@72" */; assign mul = 1'b0;


`include "defines.vh"

/*
	PLL & RTC
*/

wire 	reset,
		msec,
		sec,
		delay,
		LED,
		
		clk_5Mhz,
		clk_1MHz, 
		clk_10MHz,
		clk_400kHz;

RTC 
RTCUnit
(	 
	 .mclock		(inp_clk),		
	 .reset		(reset),		
	 .msec		(msec),			
	 .sec			(sec),			
	 .delay		(delay)			
	 .LED_FPGA	(LED),
	 
	 .clk_5Mhz		(clk_5Mhz),
	 .clk_1MHz		(clk_1MHz),
	 .clk_10MHz		(clk_10MHz),
	 .clk_400kHz	(clk_400kHz)
);	


/*
	TAHO_cnt & IMPULS detector
*/

wire [15:0] freq1, freq2, imp;

TAHO_IMPULS_TOP
TAHO_IMPULS_TOPUnit
(
	 .clock		(clk_1MHz),
	 .reset		(reset),
	 .sec			(sec),
	 .msec		(msec),
	 
	 .taho1		(taho1),
	 .taho2		(taho2),	 
	 .impuls		(impuls),	
	 
	 .freq1		(freq1),
	 .freq2		(freq2),
	 .imp			(imp)
);

/*
	GPS acquisition unit (EB-800A) 
	NMEA protocol
	GPGGA && GPRMC
*/

wire 			 GPS_ERROR;
wire [223:0] GPS_DATA;

GPS 
GPS_Unit
(
	 .clock			(clk_1MHz),
	 .reset			(reset),
	 .inGPS			(gps),
	 .GPS_DATA		(GPS_DATA),
	 .ERROR			(GPS_ERROR)
);

/*
	6 RZ (ARINC429) lines input into 16w RAM
	
	!!!!!!!!!!!!! module ARINC_429 <- starts to write from 1 wraddress
	
*/

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

/*
	ADC samples from different inp ports MUX  
*/

wire [8:0] 	rd_adau;
wire [15:0] q_adau;

ADAU 
ADAU_FRAME(
    .clock			(clock),
	 .clk_5Mhz		(clk_5Mhz),
	 .reset			(reset),
	 .msec			(msec),
	 .sec				(sec),
	 
	 .SDO				(SDO),
	 .CNV				(CNV),
	 .SDI				(SDI),
	 .CLK				(CLK),
	 
	 .ADDR			(ADDR),
	 .ENA				(ENA),
	 
	 .TX				(TX_data),
	 
	 .rd_adau		(rd_adau),
	 .q_adau			(q_adau)
);



/*
	Get's AUDIO & sends it with DATA to CC &| LPC
	
	!!!!!!!!! 	in sound_store4 & sound_store2 no FF check
					so sound channels can jump from place to place
					
					&& if ubove is set -> "case (word)" == 4 instead of 2
*/

`ifdef AUDIO // "defines.vh"
	wire aud2; 
`else 	
	wire aud2; assign aud2 = AUD2;
`endif 

	wire aud1; assign aud1 = AUD1;

Get_All_and_Trans_TOP
Get_All_and_Trans_TOP_UNIT
(
	 .clock			(inp_clk),
	 .reset			(reset),	
	 .timer			(timer),		// start of sound sampling
	 .msec			(msec),		// interupt for packages	 
	 
	 .aud1			(aud1), 
	 .aud2			(aud2),
	 .CC_tx			(TX_data_aud),
	 
	 .frame_rdy 	(frame_rdy),
	 .frame_cnt		(frame_cnt),
	 
	 .rd_FLIGHT		(rd_FLIGHT),	// [6:0]
	 .FLIGHT_out	(FLIGHT_out),	// [31:0]

`ifdef LPC	    
	 .LPC_bsy		(LPC_bsy),	// busy flag from LPC	
	 .Tx_sound		(Tx_sound1),    
`endif
	 
);

endmodule