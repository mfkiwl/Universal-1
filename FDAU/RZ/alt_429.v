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

module alt_429 (
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


// shift register
//
(* noprune *)  reg [31:0] 	arinc_buff;

always @ (posedge digi_clk) 
	arinc_buff <= {arinc_buff[30:0],line_A_sync};


	
// delay counter between packages
//
(* noprune *)		reg rst_cnt;

(* noprune *)  	reg  [ 7:0] counter;
(* noprune *)  	wire [ 7:0] counter_next;
	
always @ (posedge clock, posedge reset)
	if (reset) begin
		counter		<= 8'b0;
		rst_cnt		<= 1'b0;
	end
	else begin
		counter	<= counter_next;
		if (counter == 13) 
			rst_cnt	<= 1'b1;
		else 
			rst_cnt	<= 1'b0;
	end

assign counter_next = (digi_clk) ? 0 : counter + 1;


// bit counter for approve	
//
(* noprune *) 		reg [ 7:0] 	t_cnt;
always @ (negedge digi_clk, posedge rst_cnt)
	if (rst_cnt)
		t_cnt	<= 8'b0;
	else
		t_cnt	<= t_cnt + 8'b1;
	

//	
//// FSM to change states
localparam 	INIT_ST 			= 5'b00001,
				START_frame		= 5'b00010,	
				
				PACKAGE			= 5'b00100,			
				WR_WORD			= 5'b10000;

//sygnal declaration				
(* noprune *) reg rx_done;		
(* noprune *) reg	  wren, wren_ena;
(* noprune *) reg [ 4:0]  n_st, c_st;
(* noprune *) reg	[ 3:0]  c_addr, n_addr;
(* noprune *) reg	[31:0]  c_data, n_data;


always @ (posedge clock)begin
	if (reset) begin
		c_st 			<= INIT_ST;
		c_data		<= 0;
		c_addr		<= 0;
		wren 			<= 0;
	end
	else begin
		c_st 			<= n_st;
		wren 			<= wren_ena;
		c_addr		<= n_addr;
		c_data		<= n_data;
	end
end


always @ (*) begin

	n_st 		= c_st;
	n_addr	= c_addr;
	n_data 	= c_data;
	wren_ena = wren;
	rx_done  = 0;
	
	case (c_st)
		
		INIT_ST: begin
			if (digi_clk) begin
				n_st 		= START_frame; 
				n_addr	= 0;	
				n_data	= 0;
			end
		end
		
		START_frame: begin
			if (t_cnt == 32) 
				n_st 	= PACKAGE; 
			if (rst_cnt)
				n_st 	= INIT_ST;
		end
		
		PACKAGE: begin
			n_data 	= arinc_buff;
			n_st 		= WR_WORD;
			wren_ena	= 1;
			rx_done  = 1;
		end
		
		WR_WORD: begin
		 
			wren_ena = 0;
			
			if (digi_clk) begin
				if (counter > 70)
					n_st 	= INIT_ST;
				else begin
					n_st 		= START_frame; 
					n_addr 	= n_addr + 1;
				end
			end
		end
	endcase
end



//
//
//reg [ 7:0] 	t_cnt;
//
//always @ (posedge clock) begin
//
//	case (c_st)
//		
//		INIT_ST: 
//			t_cnt		<= 3'b0;
//		
//		START_ST: 
//			wren 		<= 1'b0;
//		
//		CNT_DELAY: 
//			t_cnt		<= t_cnt + 8'b1;
//		
//		LOOK_FOR_4T:
//			t_cnt		<= 3'b0;
//		
//		WR_WORD: 
//			data			<= arinc_buff;
//			c_addr	<= c_addr + 4'b1;
//			wren 			<= 1'b1;
//		
//	endcase
//end
//
//

//
//
//reg [31:0] 	arinc_buff;
//reg [4:0]	arinc_cnt;
//
//always @ (posedge digi_clk or posedge reset) begin 
//	if (reset) begin
//		arinc_cnt 	<= 5'b0;
//		arinc_buff	<= 32'b0;
//		c_addr	<= 4'b0;
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
//			c_addr	<= c_addr + 4'b1;
//		end	
//		
//	end
//end

//--------------------------------------------------------------------------------------------------------//


rz_ram 
rz_ram_unit(
	 .data			(c_data), 		 
	 .rdaddress		(rdaddress),	//[4:0]
	 .rdclock		(inp_clk),		//[31:0]
	 .wraddress		(c_addr),	//[3:0]	
	 .wrclock		(clock), 	// clock
	 .wren			(wren),
	 .q				(q)				//[15:0]
);

	
endmodule