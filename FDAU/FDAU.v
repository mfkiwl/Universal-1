/*
	Inner FDAU of register
*/

/*<===============
13.06.17: 


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
	 
	 .TX				(_____),	 
	  
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
	 
	 .taho1			(taho1),
	 .taho2			(taho2),
	 .impuls			(impuls),
	 
	 .rd_fdau	(rd_fdau),
	 .q_fdau		(q_fdau)
);


*/


module FDAU
(
	clock,
	clk_400kHz,
	clk_1MHz,
	clk_5Mhz,	
	reset,
	msec,
	sec,
	
	ADDR,
	ENA,
	
	CNV,
	SDI,
	CLK,
	SDO,
	
	TX,

	line_A1, line_B1,
	line_A2, line_B2,
	line_A3, line_B3,
	line_A4, line_B4,
	line_A5, line_B5,
	line_A6, line_B6,	
	
	taho1,
	taho2,
	impuls,
	
	rd_fdau,
	q_fdau
);

input  wire clock, 
				clk_400kHz,
				clk_1MHz,
				clk_5Mhz,
				reset,
				msec,
				sec;
				
input  wire 	taho1;
input  wire 	taho2;
input  wire 	impuls;


input  wire 	line_A1;
input  wire 	line_B1;

input  wire 	line_A2;
input  wire 	line_B2;

input  wire 	line_A3;
input  wire 	line_B3;

input  wire 	line_A4;				
input  wire 	line_B4;
	
input  wire 	line_A5;
input  wire 	line_B5;

input  wire 	line_A6;
input  wire 	line_B6;
	
input  wire		SDO;			
output wire 	CNV; 
output wire 	CLK; 
output wire 	SDI;
				
output wire 	TX;	//	LPC & MK
				
output wire [3:0] ADDR,
						ENA;
                 	

input wire 	[8:0] 	rd_fdau;
output wire [15:0] 	q_fdau;




//-------------------------------------------
wire 			sample_rdy;
wire [15:0]	ADC_sample;

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
	 
	 .TX				(TX),
	 
	 .sample_rdy		(sample_rdy),
	 .ADC_sample		(ADC_sample)
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
	6 RZ (ARINC429) lines input into 16w RAM
	main clk <= clk_400kHz
	!!!!!!!!!!!!! module ARINC_429 <- starts to write from 1 wraddress
	
*/


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
	 .inp_clk	(clock),
	 .reset		(reset),
	 .sec			(sec),
	 
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
///---------------------------------------------------------------------//
//(* noprune *) wire sig;
//pos_edge_det 
//pos_edge_det_Unit
//( 
//	 .sig		(sample_rdy),
//	 .clk		(clock),
//	 .pe		(sig)
//);


localparam  	INIT				= 0,
					Iddle 			= 1,//5'b00000,
					Wr_data			= 2,//5'b00001,
					Check				= 3,
					READ_TAHO_1		= 4,//5'b01100,
					READ_TAHO_2		= 5,//5'b01101,
					READ_IMPULS		= 6,//5'b01110,
					
					WAIT_one_clk	= 7,//5'b01011,
					READ_DIGI_1		= 8,//5'b00101,
					READ_DIGI_2		= 9,//5'b00110,
					READ_DIGI_3		= 10,//5'b00111,
					READ_DIGI_4		= 11,//5'b01000,
					READ_DIGI_5		= 12,//5'b01001,
					READ_DIGI_6		= 13,
					END_sample		= 14;
				
				
reg [4:0]	c_st, n_st;
reg 			wren, wr_en;
reg [8:0]  	wraddress, wr_ad;
reg [15:0]  data_adau, data;
reg [3:0] 	digi_channel, d_channel;
reg [7:0]	word_cnt, b_cnt;

reg [4:0]  	rd_arinc1,
			rd_arinc2,
			rd_arinc3,
			rd_arinc4,
			rd_arinc5,
			rd_arinc6,
			rd_ad;
	 
always @ (posedge clock)begin
	
	if (reset) begin
		
		c_st 				<= INIT;
		
		wren				<= 1'b0;
		word_cnt			<= 8'b0;
		wraddress		<= 9'b0;
		data_adau		<= 16'b0;
		digi_channel	<= 4'b0;			
		
		rd_arinc1 		<= 5'b0;
		rd_arinc2 		<= 5'b0;
		rd_arinc3 		<= 5'b0;
		rd_arinc4 		<= 5'b0;
		rd_arinc5 		<= 5'b0;
		rd_arinc6 		<= 5'b0;
		
	end
	
	else begin
		c_st 				<= n_st;
		wren				<= wr_en;
		word_cnt			<= b_cnt;
		wraddress		<= wr_ad;
		data_adau		<= data;
		digi_channel	<= d_channel;
		
		rd_arinc1 		<= rd_ad;
		rd_arinc2 		<= rd_ad;
		rd_arinc3 		<= rd_ad;
		rd_arinc4 		<= rd_ad;
		rd_arinc5 		<= rd_ad;
		rd_arinc6 		<= rd_ad;
	end
end



always @ (*) begin

	n_st 			= c_st;
	wr_en			= wren;
	wr_ad			= wraddress;
	data			= data_adau;
	d_channel	= digi_channel;	
	rd_ad			= rd_arinc1;
	b_cnt			= word_cnt;
	
	case (c_st)
	
		INIT: begin
			n_st			= Iddle;
			b_cnt			= 8'b0;
			wr_ad			= 9'b0;
			wr_en			= 1'b0;
			d_channel 	= 4'b0; 			
			rd_ad			= 5'b0;			
			data			= 16'b0;
		end
		
		Iddle: begin
			b_cnt			= 8'b0;
			wr_ad			= 9'b0;
			wr_en			= 1'b0;
			d_channel 	= 4'b0; 			
			rd_ad			= 5'b0;			
			data			= 16'b0;
			
			if (sec)
				n_st 			= Wr_data;
		end
		
		Wr_data: begin
			if (sample_rdy) begin
				n_st		= Check;				
				wr_en		= 1'b1;
				data 		= ADC_sample;				
				b_cnt		= word_cnt + 8'b1;				
			end
		end
		
		Check: begin
			 
			if (word_cnt == 65) begin
				n_st 	= READ_TAHO_1;
				b_cnt	= 8'b0;
			end
			
			else begin
				wr_en	= 1'b0;
				n_st	= END_sample;
				wr_ad	= wraddress + 9'b1;
			end			
		end	
			
		END_sample:
			if (~sample_rdy)
				n_st	= Wr_data;
		 
		READ_TAHO_1: begin
			n_st 	= READ_TAHO_2;
			data 	= freq1;
			wr_ad	= wraddress + 9'b1;
		end
		
		READ_TAHO_2: begin
			n_st 	= READ_IMPULS;
			data 	= freq2;
			wr_ad	= wraddress + 9'b1;
		end
		
		READ_IMPULS: begin
			n_st 	= READ_DIGI_1;
			data 	= imp;
			wr_ad	= wraddress + 9'b1;
		end	

		WAIT_one_clk: begin					
			case (digi_channel)
				0: n_st		= READ_DIGI_1;
				1: n_st		= READ_DIGI_2;
				2: n_st		= READ_DIGI_3;
				3: n_st		= READ_DIGI_4;
				4: n_st		= READ_DIGI_5;
				5: n_st		= READ_DIGI_6;
				6: n_st		= Iddle;
			endcase
		end	

		READ_DIGI_1: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_1_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else 
				rd_ad		= rd_arinc1  + 5'b1;
			
		end

		READ_DIGI_2: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_2_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else 
				rd_ad		= rd_arinc1  + 5'b1;
		end

		READ_DIGI_3: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_3_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else 
				rd_ad		= rd_arinc1  + 5'b1;
		end

		READ_DIGI_4: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_4_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else 
				rd_ad		= rd_arinc1  + 5'b1;
		end

		READ_DIGI_5: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_5_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else
				rd_ad		= rd_arinc1  + 5'b1;
		end

		READ_DIGI_6: begin
			
			n_st	= WAIT_one_clk;			 
			data	= arinc_6_outp; 
			wr_ad	= wraddress + 9'b1;				
			b_cnt	= word_cnt + 8'b1;
			
			if (rd_arinc1 == 31) begin 	
				rd_ad 		= 5'b0;
				d_channel	= digi_channel + 4'b1;				
			end				
			
			else 
				rd_ad		= rd_arinc1  + 5'b1;
		end
		
	endcase
end


fdau_ram // 512 words
fdau_ram_UNIT(
	 .clock			(clock),
	 .data			(data_adau), // [15:0]
	 .rdaddress		(rd_fdau),	 // [8:0]
	 .wraddress		(wraddress), // [8:0]
	 .wren			(wren),
	 .q				(q_fdau)		 // [15:0]
);

/*
reg 			wr_en;
reg [8:0]  	wraddress;
reg [15:0]  data_adau;

reg [3:0] 	digi_channel;
reg [7:0]	word_cnt;

reg [4:0]  	rd_arinc1,
				rd_arinc2,
				rd_arinc3,
				rd_arinc4,
				rd_arinc5,
				rd_arinc6;
	
reg [4:0]	st_m;	

localparam  	Iddle 			= 1,//5'b00000,
				Wr_data			= 2,//5'b00001,
				Check			= 3,//5'b00010,
				Wr_gps			= 4,//5'b00011,
				WAIT_Low_send	= 5,//5'b00100,
				
				READ_DIGI_1		= 6,//5'b00101,
				READ_DIGI_2		= 7,//5'b00110,
				READ_DIGI_3		= 8,//5'b00111,
				READ_DIGI_4		= 9,//5'b01000,
				READ_DIGI_5		= 10,//5'b01001,
				READ_DIGI_6		= 11,//5'b01010,
				WAIT_one_clk	= 12,//5'b01011,
				
				READ_TAHO_1		= 13,//5'b01100,
				READ_TAHO_2		= 14,//5'b01101,
				READ_IMPULS		= 15,//5'b01110,
				
				SEND_SYNC		= 16,//5'b01111,
				SEND_SERIAL1	= 17,//5'b10000,
				SEND_SERIAL2	= 18;//5'b10001;
	
	
always @ (posedge reset or posedge clock) begin
	if (reset) begin
	 
		st_m				<= Iddle;
		
		wr_en				<= 1'b0;
		word_cnt			<= 8'b0;
		wraddress		<=	9'b0;
		data_adau		<=	16'b0;
		digi_channel	<= 4'b0;	
		
		rd_arinc1 		<= 5'b0;
		rd_arinc2 		<= 5'b0;
		rd_arinc3 		<= 5'b0;
		rd_arinc4 		<= 5'b0;
		rd_arinc5 		<= 5'b0;
		rd_arinc6 		<= 5'b0;
		
	end
	
	else begin
		case (st_m)
		 
			Iddle: begin
			 
				wr_en	<= 1'b0;
				
				if (sec) begin
					st_m 			<= Wr_data;
					wraddress		<=	9'b0;
					digi_channel	<= 4'b0;	
				end
				
				
			end
			
			Wr_data:begin
			
				if (sample_rdy) begin
					st_m			<= Check;
					
					wr_en			<= 1'b1;
					data_adau 		<= ADC_sample;
					
					word_cnt		<= word_cnt + 8'b1;
					
				end
				
			end
			
			Check: begin
			 
				if (wraddress == 65) begin
					st_m 		<= READ_TAHO_1;
					word_cnt	<= 8'b0;
				end
				
				else begin
					st_m			<= WAIT_Low_send;
					wr_en			<= 1'b0;
					wraddress	<= wraddress + 9'b1;
				end
				
			end	
			
			WAIT_Low_send: begin
				if (~sample_rdy) 	st_m	<= Wr_data;
			end
			
			
			READ_TAHO_1: begin
				st_m 			<= READ_TAHO_2;
				data_adau 	<= freq1;
				wraddress	<= wraddress + 9'b1;
			end
			
			READ_TAHO_2: begin
				st_m 			<= READ_IMPULS;
				data_adau 	<= freq2;
				wraddress	<= wraddress + 9'b1;
			end
			
			READ_IMPULS: begin
				st_m 			<= READ_DIGI_1;
				data_adau 	<= imp;
				wraddress	<= wraddress + 9'b1;
			end			
			
			READ_DIGI_1: begin
			
				st_m		 	<= WAIT_one_clk;		
			 
				data_adau	<= arinc_1_outp; 
				wraddress	<= wraddress + 9'b1;				
			 
				if (rd_arinc1 == 31) begin 	
					rd_arinc1 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else rd_arinc1		<= rd_arinc1  + 5'b1;
			end
			
			READ_DIGI_2: begin
			
				st_m		 	<= WAIT_one_clk;		
			  
				data_adau	<= arinc_2_outp; 
				wraddress	<= wraddress + 9'b1;
				
				if (rd_arinc2 == 31) begin 	
					rd_arinc2 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end					
				
				else 	rd_arinc2		<= rd_arinc2  + 5'b1;		
					
			end
			
			READ_DIGI_3: begin
			 
				st_m		 	<= WAIT_one_clk;		
			 
				data_adau	<= arinc_3_outp; 
				wraddress	<= wraddress + 9'b1;
				
				if (rd_arinc3 == 31) begin 	
					rd_arinc3 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end						
				
				else 	rd_arinc3		<= rd_arinc3  + 5'b1;	
					
			end
			
			READ_DIGI_4: begin
			 
				st_m		 	<= WAIT_one_clk;		
			 
				data_adau	<= arinc_4_outp; 
				wraddress	<= wraddress + 9'b1;
				
				if (rd_arinc4 == 31) begin 	
					rd_arinc4 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else 	rd_arinc4		<= rd_arinc4  + 5'b1;
					
			end
			
			READ_DIGI_5: begin
			 
				st_m		 	<= WAIT_one_clk;		
			 
				data_adau	<= arinc_5_outp; 
				wraddress	<= wraddress + 9'b1;
					
				if (rd_arinc5 == 31) begin 	
					rd_arinc5 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else 	rd_arinc5		<= rd_arinc5  + 5'b1;
					
			end
			
			READ_DIGI_6: begin
			 
				st_m		 	<= WAIT_one_clk;		
			 
				data_adau	<= arinc_6_outp; 
				wraddress	<= wraddress + 9'b1;
					
				if (rd_arinc6 == 31) begin 	
					rd_arinc6 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else 	rd_arinc6		<= rd_arinc6  + 5'b1;
					
			end
			
			WAIT_one_clk: begin					
				case (digi_channel)
					0: st_m		<= READ_DIGI_1;
					1: st_m		<= READ_DIGI_2;
					2: st_m		<= READ_DIGI_3;
					3: st_m		<= READ_DIGI_4;
					4: st_m		<= READ_DIGI_5;
					5: st_m		<= READ_DIGI_6;
					6: st_m		<= Iddle;
				endcase
			end	
			
			default: st_m <= Iddle;
			
		endcase
	end
end
*/
///---------------------------------------------------------------------//


endmodule
 