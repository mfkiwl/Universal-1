//`ifndef AUDIO 
//  `include "defines.vh";
//`endif 
/*
	Get's AUDIO & sends it with DATA to CC &| LPC
*/
/* 		<=======

wire			frame_rdy;
wire [3:0]	frame_cnt;

Get_All_and_Trans_TOP
Get_All_and_Trans_TOP_UNIT
(
	 .clock			(inp_clk),
	 .reset			(reset),	
	 .timer			(delay),		// start of sound sampling
	 .msec			(msec),		// interupt for packages	 
	 
	 .aud1			(aud1), 
	 .aud2			(aud2),
	 .CC_tx			(TX_mk_aud),
	 
	 .frame_rdy 	(frame_rdy),
	 .frame_cnt		(frame_cnt),
	 
	 .rd_FLIGHT		(rd_FLIGHT),	// [7:0]
	 .FLIGHT_out	(FLIGHT_out),	// [31:0]

`ifdef LPC	    
	 .LPC_bsy		(LPC_bsy),	// busy flag from LPC	
	 .Tx_sound		(Tx_sound1),    
`endif
	 
);	
*/


module Get_All_and_Trans_TOP
(
	clock,
	reset,	
	timer,
	msec,	
	
	aud1, 
	aud2,
	
	CC_tx,
	
	frame_rdy,
	frame_cnt,
	
	rd_FLIGHT,
	FLIGHT_out,
	
`ifdef LPC	
    
	LPC_bsy,
	Tx_sound
    
`endif
);

	input wire 	clock, reset;
	
	input wire  timer, msec;//, LPC_bsy;
	
	input wire 	aud1, aud2;	
	
	output wire  CC_tx; //Tx_sound, 
	
	output reg				frame_rdy;
	output reg [3:0] 		frame_cnt;
	
	output reg [7:0] 		rd_FLIGHT;
	input wire [31:0] 	FLIGHT_out;
	
`ifdef LPC	
    
	input wire 		LPC_bsy;
	output wire 	Tx_sound;
    
`endif
	
/*
======================================================================
					Making trigger for new "FF"
======================================================================
*/	
	reg frame, stage;
	
always @ (posedge clock or posedge reset) begin
	if (reset) begin
		frame 	<= 1'b0;
		stage		<= 0;
	end
	
	else begin
		case(stage) 
		
			0: begin
				if (msec) begin
					stage 	<= 1;
					frame 	<= 1'b1;
				end	
				
				else  frame <= 1'b0;
				
			end
			
			1: begin			
			
				frame <= 1'b0;		
				
				if(~msec)	stage	<= 0;	
				
			end
			
		endcase
	end
end




/*================================================================*/
`ifdef AUDIO	//	FOUR channels of SOUND	from ONE source ("defines.vh")
/*================================================================*/	
	
	wire 	[31:0]	s_data;	
	reg 	[8:0] 	rd_SOUND;			
	wire 	[13:0]  	bytes_written;
	
	sound_store4 sound_storeUnit(
		 .reset			(reset),
		 .rst				(frame),
		 .clock			(clock),
		  
		 .Rx					(aud1),
		 .bytes_written	(bytes_written),			// [13:0]	
		 .rdaddress			(rd_SOUND),					// [8:0]
		 .q					(s_data)					//	[15:0]	
	);
	
wire [31:0] sound; assign sound = s_data;
	
/*================================================================*/
`else 	//	FOUR channels of SOUND	from TWO sources
/*================================================================*/

	wire [15:0]		s1_data,	s2_data;
	reg 	[8:0] 	rd_SOUND;
	wire [13:0]  	bytes_written1 , bytes_written2;
	
	sound_store2 sound_storeUnit1(
		 .reset			(reset),
		 .rst				(frame),
		 .clock			(clock),
		  
		 .Rx					(aud1),
		 .bytes_written	(bytes_written1),			// [13:0]	
		 .rdaddress			(rd_SOUND),					// [8:0]
		 .q					(s1_data)					//	[15:0]
	);
//--------------------------------------------
	sound_store2 sound_storeUnit2(
		 .reset			(reset),
		 .rst				(frame),
		 .clock			(clock),
		  
		 .Rx					(aud2),
		 .bytes_written	(bytes_written2),			// [13:0]	
		 .rdaddress			(rd_SOUND),					// [8:0]
		 .q					(s2_data)					//	[15:0]	
	);

wire [31:0] sound; assign sound = {s2_data,s1_data};

/*================================================================*/
`endif	 //
/*================================================================*/


reg 			wren; 
reg [9:0]  	cc_wr;
reg [12:0]	wraddress;
reg [31:0]  cc_in,
				cnt;

reg [2:0] state/* synthesis syn_encoding = "safe, one-hot" */;
localparam	WAIT_FRAME 		= 3'b000,
				READ_SOUND 		= 3'b001,
				WAIT_one_clk	= 3'b010,
				READ_PARAM		= 3'b011,
				WAIT_START		= 3'b100,
				ZERO				= 3'b101,
				FLIGHT			= 3'b110,
				CNT				= 3'b111;


reg [7:0] param_cnt;
//reg [2:0] frame_cnt;

always @ (posedge reset or posedge clock) begin
	if (reset) begin
	 
		state 			<= WAIT_START;
		wren				<= 1'b0;
		cc_in				<= 32'b0;
		
		CC_RDY			<= 1'b0;
		wraddress		<= 13'b0;
		cc_wr				<= 10'b0;
		rd_SOUND			<= 9'b0;
		
		param_cnt		<= 8'b0;
		
		frame_rdy		<= 1'b0;
		frame_cnt		<= 4'd0;
		
		rd_FLIGHT		<= 8'b0;
		
		cnt				<= 32'b0;
	end
	
	else begin
		case (state)
		
			WAIT_START: begin
			 
				if (timer) state <= WAIT_FRAME;			
				
			end
			
			WAIT_FRAME: begin
				
				wren 		<= 1'b0;
				
				if (msec) begin
					frame_cnt	<= frame_cnt + 4'b1;
					frame_rdy	<= 1'b1;
				//------------------------------------------
					wren			<= 1'b1;
					cc_in			<= sound;//{s2_data,s1_data};
					cc_wr			<= 10'b0;
					rd_SOUND		<= rd_SOUND  + 9'b1;
					
				//------------------------------------------	
					
					state 		<= WAIT_one_clk;
				end
				
			end
			
			WAIT_one_clk: begin				
				
				frame_rdy	<= 1'b0;
				
				if (rd_SOUND == 500)	 state <= READ_PARAM; //state <= CNT;	//  
				
				else  					 state <= READ_SOUND;
				
			end
			
			READ_SOUND: begin
			//------------------------------------------
				wren				<= 1'b1;
				cc_in				<= sound;//{s2_data,s1_data};
				cc_wr				<= cc_wr	+ 10'b1;	
				rd_SOUND			<= rd_SOUND  + 9'b1;
				wraddress		<= wraddress + 13'b1;
			//------------------------------------------	
				state <= WAIT_one_clk;			
			end
			
			READ_PARAM: begin
				state <= FLIGHT;
			end
			
			FLIGHT: begin		
				 
				wraddress		<= wraddress + 13'b1;
					
				if (param_cnt == 12) begin //	if (param_cnt == `SUBFRAME_D / 4) begin	//	
					
					state 		<= ZERO;	
					
					CC_RDY			<= 1'b1;	
					rd_SOUND			<= 9'b0;
					param_cnt		<= 8'b0;
					
				end
				
				else begin		 
					
					state 		<= READ_PARAM;
					param_cnt	<= param_cnt + 8'b1;	
				//------------------------------------------
					cc_in				<= FLIGHT_out;			
					rd_FLIGHT		<= rd_FLIGHT  + 8'b1;
				//------------------------------------------
					cc_wr				<= cc_wr	+ 10'b1;		
				
				end				
			end
			
			ZERO: begin
				state  	<= WAIT_FRAME;
				wren 		<= 1'b0;
				CC_RDY	<= 1'b0;
				
			if (rd_FLIGHT >= PARAMS) 	rd_FLIGHT	<= 8'b0; // `FRAME_SIZE_D ("defines.vh")

			end
			
		endcase
	end
end

`ifdef	CFDR	// look in "defines.vh"
	parameter PARAMS = 48;
`else 
	parameter PARAMS = 48;
`endif	


wire	[11:0] 	cc_rd;
wire	[7:0]  	cc_data;

reg CC_RDY;

/*
bigger [10]cc_wr/[11]cc_rd 
helps to write 2^10 = 1024 * 4 = 4096 bytes 
to transfer through CC_transmitUnit
*/
CC_ram CC_ramUnit(
	 .clock			(clock),
	 .data			(cc_in),
	 .rdaddress		(cc_rd),
	 .wraddress		(cc_wr),
	 .wren			(wren),	
	 .q				(cc_data)
);



CC_transmit CC_transmitUnit(
	 .reset				(reset),
	 .clock				(clock),
	 
	 .RDY					(CC_RDY),	
	 
	 .rdaddress			(cc_rd),			// [10:0]
	 .data				(cc_data),		//[7:0]
	 
	 .tx					(CC_tx)
);

/*================================================================*/
`ifdef LPC	//	TRANSMITs stored DATA to LPC ("defines.vh")
/*================================================================*/	

	wire [31:0] data;		assign data  = cc_in;

	LPC_all_buff LPC_all_buff_UNIT(
		 .clock			(clock),
		 .data			(data),			// [31:0]
		 .rdaddress		(rdaddress),	// [14:0]
		 .wraddress		(wraddress),	// [12:0]
		 .wren			(wren),	
		 .q				(q)				// [7:0]
	);
	//---------------------------------------------------------------
	reg [3:0] buff_RDY;

	always @ ( posedge reset or posedge clock) begin
		if (reset) begin
			buff_RDY	<= 4'b0;
		end
		
		else begin
			if (frame_rdy) 			buff_RDY	<= buff_RDY + 4'b1;
			if (packet_SENT) 	buff_RDY	<= buff_RDY - 4'b1;
		end
	end
	//---------------------------------------------------------------
	wire 			packet_SENT;
	wire [7:0]	q;
	wire [14:0] rdaddress;
	wire [11:0] real_pack;

	LPC_tx LPC_txUnit(
		 .reset				(reset),
		 .clock				(clock),
		 
		 .buff_RDY			(buff_RDY),		// [3:0]
		 .packet_SENT		(packet_SENT),
		 
		 .rdaddress			(rdaddress),	// [14:0]
		 .data				(q),				// [7:0]
		 
		 .LPC_bsy			(LPC_bsy),
		 .tx					(Tx_sound),
		 .real_pack			(real_pack)
	);
/*================================================================*/
`endif	 //
/*================================================================*/

	
endmodule
