module aTOP_ARCTIUM
(
	inp_clk,
	
	gps,
	
	AUD1,	
	
	ADDR,
	ENA,
	
	CNV,
	SDI,
	CLK,
	SDO,
	
	TX_data,
	CC_tx,
	
	line_A1, line_B1,
	line_A2, line_B2,
	line_A3, line_B3,
	line_A4, line_B4,
	line_A5, line_B5,
	line_A6, line_B6,	
	
	taho1,
	taho2,
	impuls,
	line_A21, line_B21,	line_A31, line_B31,	line_A41, line_B41,	line_A51, line_B51,	line_A61, line_B61,
	
	LED_FPGA,
	
	div,
	mul
);

input  wire 	inp_clk		/* synthesis altera_chip_pin_lc="@91" */;					
input  wire 	AUD1			/* synthesis altera_chip_pin_lc="@38" */;

input  wire 	gps			/* synthesis altera_chip_pin_lc="@137" */;


output wire div				/* synthesis altera_chip_pin_lc="@73" */;	assign div = 1'b1;
output wire mul				/* synthesis altera_chip_pin_lc="@72" */; assign mul = 1'b0;


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
	
input  wire		SDO			/* synthesis altera_chip_pin_lc="@50" */;			
output wire 	CNV			/* synthesis altera_chip_pin_lc="@51" */; 
output wire 	CLK			/* synthesis altera_chip_pin_lc="@52" */; 
output wire 	SDI			/* synthesis altera_chip_pin_lc="@53" */;

output wire [3:0] ADDR,
						ENA;

input  wire 	taho1			/* synthesis altera_chip_pin_lc="@31" */;
input  wire 	taho2			/* synthesis altera_chip_pin_lc="@32" */;
input  wire 	impuls		/* synthesis altera_chip_pin_lc="@142" */;
	
output wire 	TX_data 		/* synthesis altera_chip_pin_lc="@143" */;	//	LPC & MK	

output wire  	CC_tx 		/* synthesis altera_chip_pin_lc="@30" */; //Tx_sound, 

output wire 	LED_FPGA		/* synthesis altera_chip_pin_lc="@138" */;
/*
Get_All_and_Trans_TOP:
FDAU:
RTC:	
*/
	 input  wire 	line_A21						/* synthesis altera_chip_pin_lc="@77" */;		
	 input  wire 	line_A31						/* synthesis altera_chip_pin_lc="@84" */;		
	 input  wire 	line_A41						/* synthesis altera_chip_pin_lc="@88" */;			 
	 input  wire 	line_A51						/* synthesis altera_chip_pin_lc="@99" */;		
	 input  wire 	line_A61						/* synthesis altera_chip_pin_lc="@104" */;		
	 
	 input  wire 	line_B21						/* synthesis altera_chip_pin_lc="@80" */;		
	 input  wire 	line_B31						/* synthesis altera_chip_pin_lc="@86" */;		
	 input  wire 	line_B41						/* synthesis altera_chip_pin_lc="@90" */;			
	 input  wire 	line_B51						/* synthesis altera_chip_pin_lc="@111" */;		
	 input  wire 	line_B61						/* synthesis altera_chip_pin_lc="@106" */;		



parameter serial_number = "RP24";
`include "defines.vh"

wire d_lineA1; wire d_lineB1;
wire d_lineA2; wire d_lineB2;
wire d_lineA3; wire d_lineB3;
wire d_lineB4; wire d_lineA4;
wire d_lineB5; wire d_lineA5;
wire d_lineA6; wire d_lineB6;

assign  d_lineB1 	= line_A31 & line_A3;
assign  d_lineA1	= line_B31 & line_B3;

assign  d_lineB2	= line_A61 & line_A6;
assign  d_lineA2	= line_B61 & line_B6;

assign  d_lineB3	= line_A21 & line_A2;
assign  d_lineA3	= line_B21 & line_B2;

assign  d_lineB4	= line_A51 & line_A5;
assign  d_lineA4	= line_B51 & line_B5;

assign  d_lineA5	= line_A1;
assign  d_lineB5	= line_B1;

assign  d_lineB6	= line_A41 & line_A4;
assign  d_lineA6	= line_B41 & line_B4;




/*
	PLL & RTC
*/

wire 	reset,
		msec,
		sec,
		delay,
		
		clk_5Mhz,
		clk_1MHz, 
		clk_10MHz,
		clk_400kHz,
		
		SYNC;	// <======

RTC 
RTCUnit
(	 
	 .mclock		(inp_clk),		
	 .reset		(reset),			
	 .SYNC		(SYNC),
	 
	 .msec		(msec),			
	 .sec			(sec),			
	 .delay		(delay),		
	 .LED_FPGA	(LED_FPGA),
	 
	 .clk_5Mhz		(clk_5Mhz),
	 .clk_1MHz		(clk_1MHz),
	 .clk_10MHz		(clk_10MHz),
	 .clk_400kHz	(clk_400kHz)
);	


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
	Inner FDAU of register
*/
wire 	[8:0] 	rd_fdau;
wire [15:0] 	q_fdau;

FDAU 
FDAU
(
    .clock			(inp_clk),
	 .clk_400kHz	(clk_400kHz),
	 .clk_1MHz		(clk_1MHz),
	 .clk_5Mhz		(clk_5Mhz),
	 .reset			(reset),
	 .msec			(msec),
	 .sec				(sec),
	 
	 .ADDR			(ADDR),
	 .ENA				(ENA),
	 
	 .CNV				(CNV),
	 .SDI				(SDI),
	 .CLK				(CLK),
	 .SDO				(SDO),	 
	 
	 .TX				(TX_data),	 
	  
	 .line_A1	(d_lineA1),
	 .line_B1	(d_lineB1),
	 .line_A2	(d_lineA2),
	 .line_B2	(d_lineB2),
	 .line_A3	(d_lineA3),
	 .line_B3	(d_lineB3),
	 .line_A4	(d_lineA4),
	 .line_B4	(d_lineB4),
	 .line_A5	(d_lineA5),
	 .line_B5	(d_lineB5),
	 .line_A6	(d_lineA6),
	 .line_B6	(d_lineB6),
	 
	 .taho1			(taho1),
	 .taho2			(taho2),
	 .impuls			(impuls),
	 
	 .rd_fdau	(rd_fdau),
	 .q_fdau		(q_fdau)
);


/*
	Prev Flight_DATA -> all parametric data available
*/

wire [7:0] 	rd_FLIGHT;
wire [31:0] FLIGHT_out;

SUBFRAME_FORMER 
SUBFRAME_FORMER_UNIT
(
	 .clock			(inp_clk),
	 .reset			(reset),
	 
	 .frame 			(frame_rdy),
	 .frame_cnt		(frame_cnt),
	 
	 .GPS_DATA		(GPS_DATA),		// [223:0]		
	 .I2C_DATA		(I2C_DATA),		// [159:0] 
	 
	 .rd_fdau		(rd_fdau),
	 .q_fdau			(q_fdau),
	 
	 .rd_FLIGHT		(rd_FLIGHT),	// [7:0]
	 .FLIGHT_out	(FLIGHT_out),	// [31:0]
	 
	 .serial_number (serial_number) // <= defines.vh
);

/*
	Get's AUDIO & sends it with DATA to CC &| LPC
	
	!!!!!!!!! 	in sound_store4 & sound_store2 no FF check
					so sound channels can jump from place to place
					
					&& if ubove is set -> "case (word)" == 4 instead of 2
*/

`ifdef AUDIO // "defines.vh"
	wire AUD2; 
`endif 

wire			frame_rdy;
wire [3:0]	frame_cnt;

Get_All_and_Trans_TOP
Get_All_and_Trans_TOP_UNIT
(
	 .clock			(inp_clk),
	 .reset			(reset),	
	 .timer			(delay),		// start of sound sampling
	 .msec			(msec),		// interupt for packages	 
	 
	 .aud1			(AUD1), 
	 .aud2			(AUD2),
	 .CC_tx			(CC_tx),
	 
	 .frame_rdy 	(frame_rdy),
	 .frame_cnt		(frame_cnt),
	 
	 .rd_FLIGHT		(rd_FLIGHT),	// [6:0]
	 .FLIGHT_out	(FLIGHT_out)	// [31:0]

`ifdef LPC
	 ,	    
	 .LPC_bsy		(LPC_bsy),	// busy flag from LPC	
	 .Tx_sound		(Tx_sound1)    
`endif
	 
);

endmodule