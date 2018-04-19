/*
ARINC_429
ARINC_429_1(
	 .clock			(clk_400kHz),
	 .inp_clk		(inp_clk),
	 .reset			(reset),
	 .line_A			(line_A),
	 .line_B			(line_B),
	 .rdaddress		(rd_arinc1),
	 .q				(arinc_1_outp)
);
*/

module ARINC_429 (
clock,
inp_clk,
reset,
line_A,
line_B,

rdaddress,
q
);


	input wire	clock,
					inp_clk, 
					reset, 
					line_A, line_B;
					
	input wire	[4:0]  rdaddress;
	
	output wire	[15:0]  q;

	
wire line_A_sync;
Sync_input Sync_input_line_A(
	.clock			(clock),
	.signal			(line_A),
	.signal_sync	(line_A_sync)
);
wire line_B_sync;
Sync_input Sync_input_line_B(
	.clock			(clock),
	.signal			(line_B),
	.signal_sync	(line_B_sync)
);

	
wire digi_clk;		assign digi_clk = line_A_sync || line_B_sync;
//--------------------------------------------------------------------------------------------------------//

reg [31:0] 	arinc_buff;
reg [ 4:0] 	digi_cnt;
always @ (posedge digi_clk or posedge d_rst) begin
	if (d_rst) begin
		arinc_buff 	<= 32'b0;
		digi_cnt		<= 5'b0;
	end
	else begin
		
		arinc_buff 	<= {arinc_buff[30:0],line_A_sync};
		digi_cnt		<= digi_cnt + 5'b1;
		
	end
end
//
//
//always @ (posedge clock) begin
//	if (digi_clk) begin
//		if ((t_cnt > 15)&(t_cnt < 200)) begin
//			data			<= arinc_buff;
//			wraddress	<= wraddress + 4'b1;
//			wren 			<= 1'b1;
//			t_cnt			<= 8'b0;
//		end
//		else if (t_cnt > 200) t_cnt <= 8'b0;
//	end
//	
//	else begin
//		if (t_cnt == 255) t_cnt <= t_cnt;
//		else 					t_cnt	<= t_cnt + 8'b1;
//	end
//end
//
//
//


reg 			d_rst;
reg [ 5:0] n_st, c_st;

localparam 	INIT_ST 			= 6'b000001,
				WT_START			= 6'b000010,				
				CNT_DELAY		= 6'b000100,
				LOOK_FOR_4T		= 6'b001000,				
				WR_WORD			= 6'b010000,
				IDDLE				= 6'b100000;

always @ (*) begin

	n_st = c_st;
	
	case (c_st)
	 
		IDDLE:
			n_st = INIT_ST;
		
		INIT_ST: 
			if (digi_clk) 	n_st = WT_START;
		
		WT_START:		
			if (~digi_clk)	n_st = CNT_DELAY;			
		
		CNT_DELAY: begin
			if (digi_clk)	  n_st = LOOK_FOR_4T;
			if (t_cnt >= 13) n_st = WR_WORD;
		end
		
		LOOK_FOR_4T:
			n_st = WT_START;
		
		WR_WORD: 
			n_st = INIT_ST;
		
	endcase
end

always @ (posedge clock)begin
	if (reset)  	c_st <= IDDLE;
	else 				c_st <= n_st;
end


reg [ 7:0] 	t_cnt;

always @ (posedge clock) begin

	case (c_st)
		IDDLE: begin
			t_cnt			<= 3'b0;
			wren 			<= 1'b0;
			data			<= 32'b0;
			wraddress	<= 4'b0;
		end
		
		INIT_ST: 
			t_cnt		<= 3'b0;
		
		WT_START: 
			wren 		<= 1'b0;
		
		CNT_DELAY: 
			t_cnt		<= t_cnt + 8'b1;
		
		LOOK_FOR_4T: 
			t_cnt			<= 3'b0;
		
		WR_WORD: begin			
			wren 			<= 1'b1;
			data			<= arinc_buff;
			wraddress	<= wraddress + 4'b1;
		end
		
	endcase
end

//
//
//reg [31:0] 	arinc_buff;
//reg [4:0]	arinc_cnt;
//
//always @ (posedge digi_clk or posedge reset) begin 
//	if (reset) begin
//		arinc_cnt 	<= 5'b0;
//		arinc_buff	<= 32'b0;
//		wraddress	<= 4'b0;
//		wren 			<= 1'b0;
//	end
//	
//	else begin
//	 
//		wren 			<= 1'b1;
//		arinc_cnt 	<= arinc_cnt + 5'b1;
//		arinc_buff [arinc_cnt] <= line_A_sync;
//		
//		if (arinc_cnt == 0) begin
//			data			<= arinc_buff;
//			wraddress	<= wraddress + 4'b1;
//		end	
//		
//	end
//end

//--------------------------------------------------------------------------------------------------------//
	reg	  wren;
	reg	[31:0]  data;
	reg	[3:0]  wraddress;

rz_ram 
rz_ram_unit(
	 .data			(data), 		 
	 .rdaddress		(rdaddress),	//[4:0]
	 .rdclock		(inp_clk),		//[31:0]
	 .wraddress		(wraddress),	//[3:0]	
	 .wrclock		(clock), 		// clock
	 .wren			(wren),
	 .q				(q)				//[15:0]
);

	
endmodule