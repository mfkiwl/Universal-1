/*
wire [6:0] 	rd_FLIGHT;
wire [31:0] FLIGHT_out;

Flight_data Flight_dataUnit(
	 .clock			(clock),
	 .reset			(reset),
	 
	 .frame 			(RDY),
	 .frame_cnt		(frame_cnt),
	 
	 .GPS_DATA		(GPS_DATA),		// [223:0]		
	 .I2C_DATA		(I2C_DATA),		// [159:0] 
	 
	 .rd_MSRP		(rd_BUR),
	 .MSRP_data		(BUR_dat),
	
	 .rd_FLIGHT		(rd_FLIGHT),	// [6:0]
	 .FLIGHT_out	(FLIGHT_out),	// [31:0]
	 
	 .Serial_number (Serial_number)
);
*/

module Flight_data (
	clock,
	reset,
	
	frame,
	frame_cnt,
	
	GPS_DATA,
	I2C_DATA,
	
	rd_MSRP,
	MSRP_data,
	
	rd_FLIGHT,
	FLIGHT_out,
	
	Serial_number
);

	input wire clock, reset, frame;
	input wire [3:0] 		frame_cnt;
	
	input wire [223:0] GPS_DATA;
	input wire [159:0] I2C_DATA;	
	
	
	output reg [7:0] 	rd_MSRP;
	input wire [15:0] MSRP_data;
		
	input  wire [6:0] 	rd_FLIGHT;
	output wire [31:0] 	FLIGHT_out;
	
	input wire [31:0] 	Serial_number;


	
	reg [223:0] GPS_buff;
	reg [159:0] I2C_buff;	
	
	reg wren;
	reg [5:0] 	byte_cnt;
	reg [7:0] 	wraddress;
	reg [15:0]	data, cnt;
	
//---------------------------------------------
wire [1:0] subframe; assign subframe = frame_cnt [3:2];
//---------------------------------------------
	

	reg [3:0] state;
	localparam 	IDDLE 			= 4'b0000,
					READ_I2C			= 4'b0001,
					READ_GPS			= 4'b0010,
					READ_MSRP		= 4'b0011,
					READ_DOP			= 4'b0100,
					WAIT_CYCLE		= 4'B0101,
					WAIT_LOW			= 4'b0110,
					CNT				= 4'b0111,
					PUT_SERIAL_1	= 4'b1000,
					PUT_SERIAL_2	= 4'b1001,
					SUBFRAME 		= 4'b1010;

always @(posedge reset or posedge clock)
begin
	
	if (reset) begin
		
		state		<= IDDLE;
		
		wren 			<= 1'b0;
		data			<= 16'h0;
		wraddress	<= 8'b0;
		
		GPS_buff		<= 224'b0;
		I2C_buff		<= 160'b0;
		
		rd_MSRP		<= 8'b0;
		
		byte_cnt 	<= 6'b0;	
		cnt			<= 16'b0;
	end
	
	else begin
		case(state)
		 
			IDDLE: begin
				if (frame) begin
					state <= SUBFRAME;//CNT;
					
					wren 			<= 1'b1;
					data			<= 16'hff7f;	
					
					byte_cnt		<= 6'b0;
//					rd_MSRP		<= 8'b0;
					
					GPS_buff		<= GPS_DATA;
					I2C_buff		<= I2C_DATA;
					
				end
				else 	begin
					state			<= IDDLE;
					wren 			<= 1'b0;
					data			<= 16'h0;
					wraddress	<= 8'b0;					
					byte_cnt		<= 6'b0;
				end
			end
			
			SUBFRAME: begin
				state <= CNT;
				case(subframe)
					2'b00:	rd_MSRP	<= 8'b0;
					2'b01:	rd_MSRP	<= 8'd64;
					2'b10:	rd_MSRP	<= 8'd128;
					2'b11:	rd_MSRP	<= 8'd192;
				endcase
			end
			
			CNT: begin	
				state 		<= READ_I2C;
				data			<= cnt;
				cnt 			<= cnt + 16'b1;				
				wraddress	<= wraddress + 8'b1;							
			end
			
			READ_I2C: begin
			 
				if (byte_cnt == 10) begin 	//(i2c_data == 7) 	
					byte_cnt <= 6'b0;					
					state 	<= READ_GPS;
				end
				
				else begin 	
					state 		<= READ_I2C;
					byte_cnt 	<= byte_cnt + 6'b1;
					
					data 			<= I2C_buff [15:0];
					wraddress	<= wraddress + 8'b1;
					I2C_buff 	<= I2C_buff >> 16;				
					
				end
				
			end
			
			READ_GPS: begin
			 
				if (byte_cnt == 14) begin 	
					byte_cnt <= 6'b0;					
					state 	<= READ_MSRP;					
				end
				
				else begin 	
					state 		<= READ_GPS;
					byte_cnt 	<= byte_cnt + 6'b1;
					
					data 			<= GPS_buff [15:0];
					wraddress	<= wraddress + 8'b1;
					GPS_buff 	<= GPS_buff >> 16;				
					
				end
				
			end
			
			READ_MSRP: begin
				data			<= MSRP_data;
				rd_MSRP		<= rd_MSRP + 8'b1;
				byte_cnt 	<= byte_cnt + 6'b1;
				wraddress	<= wraddress + 8'b1;
				
				if (byte_cnt == 63) 	state 	<= READ_DOP;
				
				else 						state 	<= WAIT_CYCLE;
				
			end
			
			WAIT_CYCLE: state <= READ_MSRP;
			
			READ_DOP: begin
			 
				if (byte_cnt == 4) begin 	
					byte_cnt <= 6'b0;					
					state 	<= PUT_SERIAL_1;					
				end
				
				else begin 	
					state 		<= READ_DOP;
					byte_cnt 	<= byte_cnt + 6'b1;
					
					data 			<= 16'b0;//ZAK_buff [15:0];
					wraddress	<= wraddress + 8'b1;
					//ZAK_buff 	<= ZAK_buff >> 16;				
					
				end
				
			end
			
			PUT_SERIAL_1: begin
			 
				state 		<= PUT_SERIAL_2;
				
				data 			<= {Serial_number [23:16],Serial_number [31:24]};
				wraddress	<= wraddress + 8'b1;		
				
			end
			
			PUT_SERIAL_2: begin
			 
				state 		<= WAIT_LOW;
				
				data 			<= {Serial_number [7:0],Serial_number [15:8]};
				wraddress	<= wraddress + 8'b1;			
				
			end
			
			WAIT_LOW: begin
				if (~frame) state 	<= IDDLE;	
			end
			
		endcase
	end
end

MSRP MSRP_RAM(
	 .clock			(clock),
	 .data			(data),			// [15:0]
	 .rdaddress		(rd_FLIGHT),	// [6:0]
	 .wraddress		(wraddress),	// [7:0]
	 .wren			(wren),
	 .q				(FLIGHT_out)	// [31:0]
);

endmodule