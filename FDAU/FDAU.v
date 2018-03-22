/*
13.06.17: 


input  wire clk_5Mhz, reset, msec, SDO;
output wire CNV, CLK, TX;
output wire [3:0] 	ADDR, ENA;

wire 			sample_rdy;
wire [15:0] ADC_sample;		

FDAU 
FDAU
(
    .clock			(inp_clk),
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
	 .arinc_6_outp	(arinc_6_outp),
	 
	 .freq1		(freq1),
	 .freq2		(freq2),
	 .imp			(imp),
	 
	 .rd_adau	(rd_adau),
	 .q_adau		(q_adau)
);


*/


module FDAU
(
	clock,
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
		
	rd_arinc1,
	rd_arinc2,
	rd_arinc3,
	rd_arinc4,
	rd_arinc5,
	rd_arinc6,
	
	arinc_1_outp,
	arinc_2_outp,
	arinc_3_outp,
	arinc_4_outp,
	arinc_5_outp,
	arinc_6_outp,
	
	freq1,
	freq2,
	imp,
	
	rd_adau,
	q_adau
);

input  wire clk_5Mhz,
				clock, 
				reset,
				msec,
				sec,
				
				SDO;				
output wire CNV,
				SDI, 
				CLK,
				
				TX;
				
output reg [3:0] 	ADDR,
						ENA;
                  
output reg [4:0] 	rd_arinc1,
						rd_arinc2,
						rd_arinc3,
						rd_arinc4,
						rd_arinc5,
						rd_arinc6;
						
input wire [15:0] arinc_1_outp,
						arinc_2_outp,
						arinc_3_outp,
						arinc_4_outp,
						arinc_5_outp,
						arinc_6_outp,
						
						freq1,
						freq2,
						imp;		
						
input wire 	[8:0] 	rd_adau;
output wire [15:0] 	q_adau;

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
//-------------------------------------------
reg 			wr_en;
reg [8:0]  	wraddress;
reg [15:0]  data_adau;

reg [3:0] 	digi_channel;
reg [7:0]	word_cnt;
reg [4:0]	st_m	/* synthesis syn_encoding = "safe, one-hot" */;

localparam  Iddle 			= 1,//5'b00000,
				Wr_data			= 2,//5'b00001,
				Check				= 3,//5'b00010,
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
				if (sec) begin
					st_m 				<= Wr_data;
					wraddress		<=	9'b0;
					digi_channel	<= 4'b0;	
				end
				
				else begin
					wr_en	<= 1'b0;
					st_m	<= Iddle;
				end
				
			end
			
			Wr_data:begin
				if (sample_rdy) begin
					wr_en			<= 1'b1;
					data_adau 	<= SEND_pack;
					
					word_cnt		<= word_cnt + 8'b1;
					
					st_m			<= WAIT_Low_send;
				end
				
				else st_m <= Wr_data;
			end
			
			WAIT_Low_send: begin
				if (~sample_rdy) 	st_m	<= Check;
				else 					st_m	<= WAIT_Low_send;
			end
			
			Check: begin
				if (word_cnt == 65) begin
					wr_en		<= 1'b1;
					st_m 		<= READ_TAHO_1;
					word_cnt	<= 8'b0;
				end
				
				else begin
					wr_en			<= 1'b0;
					st_m			<= Wr_data;
					wraddress	<= wraddress + 9'b1;
				end
				
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
			 
				data_adau	<= arinc_1_outp; 
				wraddress	<= wraddress + 9'b1;
				
				st_m		 	<= WAIT_one_clk;		
			 
				if (rd_arinc1 == 31) begin 	
					rd_arinc1 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else rd_arinc1		<= rd_arinc1  + 5'b1;
			end
			
			READ_DIGI_2: begin
			 
				data_adau	<= arinc_2_outp; 
				wraddress	<= wraddress + 9'b1;
				
				st_m		 	<= WAIT_one_clk;		
			 
				if (rd_arinc2 == 31) begin 	
					rd_arinc2 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end					
				
				else 	rd_arinc2		<= rd_arinc2  + 5'b1;		
					
			end
			
			READ_DIGI_3: begin
			 
				data_adau	<= arinc_3_outp; 
				wraddress	<= wraddress + 9'b1;
				
				st_m		 	<= WAIT_one_clk;		
			 
				if (rd_arinc3 == 31) begin 	
					rd_arinc3 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end						
				
				else 	rd_arinc3		<= rd_arinc3  + 5'b1;	
					
			end
			
			READ_DIGI_4: begin
			 
				data_adau	<= arinc_4_outp; 
				wraddress	<= wraddress + 9'b1;
				
				st_m		 	<= WAIT_one_clk;		
			 
				if (rd_arinc4 == 31) begin 	
					rd_arinc4 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else 	rd_arinc4		<= rd_arinc4  + 5'b1;
					
			end
			
			READ_DIGI_5: begin
			 
				data_adau	<= arinc_5_outp; 
				wraddress	<= wraddress + 9'b1;
					
				st_m		 	<= WAIT_one_clk;		
			 
				if (rd_arinc5 == 31) begin 	
					rd_arinc5 		<= 5'b0;
					digi_channel	<= digi_channel + 4'b1;				
				end				
				
				else 	rd_arinc5		<= rd_arinc5  + 5'b1;
					
			end
			
			READ_DIGI_6: begin
			 
				data_adau	<= arinc_6_outp; 
				wraddress	<= wraddress + 9'b1;
					
				st_m		 	<= WAIT_one_clk;		
			 
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
		endcase
	end
end


adau_ram
adau_ram_UNIT(
	 .clock			(clock),
	 .data			(data_adau),
	 .rdaddress		(rd_adau),
	 .wraddress		(wraddress),
	 .wren			(wr_en),
	 .q				(q_adau)
);


endmodule
 