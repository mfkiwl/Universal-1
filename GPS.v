/*
	GPS acquisition unit (EB-800A) 
	NMEA protocol
	GPGGA && GPRMC
*/

/* <===========

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

*/

module GPS (
clock,
reset,
inGPS,

GPS_DATA,
ERROR
);


input wire 	clock,
				reset,
				inGPS;

output reg [223:0] GPS_DATA;
output reg ERROR;


wire GPS;
Sync_input Sync_GPS(
	.clock			(clock),
	.signal			(inGPS),
	.signal_sync	(GPS)
);


reg [7:0] byte;
reg [47:0] ID;
reg TIC;

wire [3:0] halfByte; 	assign halfByte = byte[3:0];

////////////////////////////////////////////////////////////////
/////////////////////// UART RECEIVE ///////////////////////////
////////////////////////////////////////////////////////////////
localparam IDLE=0,BYTE=1,START=2;

reg[7:0] count;
reg [3:0] counter;
reg [4:0] state;
reg [7:0] data;

always @ (posedge clock) begin
	if (reset)begin
		state 	<= IDLE;
		count 	<= 8'b0;		// bit number
		counter 	<= 4'b0;	// tics till next bit
		data 		<= 8'b0;
		ID 		<= 48'b0;
		TIC 		<= 1'b0;
	end
	else begin	
		case (state)	
		
			IDLE: begin
				counter <= 4'd0;
				
				if (~GPS) begin
					state 	<= START;
					ID[7:0] 	<= byte;
				end
				
				else state <= IDLE;
			end
			
			START: begin
				
/*=>25*/		if (counter == 7)begin 
					state 	<= BYTE;
					counter 	<= 4'b0;
					TIC 		<= 1'b1;
				end
				
				else begin
					state 	<= START;
					counter 	<= counter + 4'b1;
				end
				
			end
			
			BYTE: begin
			 
				counter <= counter + 4'b1;
/*=>13*/		if (counter == 4)begin
					data[count] <= GPS;
					count <= count + 8'd1;
				end
				
/*=>25*/		else if (counter == 8) begin
					if (count == 8) begin
						state <= IDLE;
						count <= 0;
						byte <= data;
						TIC <=1'b0;
						ID <= ID <<< 8;
					end
					else counter <= 4'b0;
				end
				
				else state <= BYTE;
				
			end
		endcase
	end
end
////////////////////////////////////////////////////////////////				
////////////////////////////////////////////////////////////////

reg  [31:0] altitude;
wire [15:0] altitude_H, altitude_L;		

			assign altitude_H = altitude [31:16];
			assign altitude_L = altitude [15:0];

reg [15:0] 	T_hour,
				T_minutes,
				T_seconds,
				
				D_day,
				D_month,
				D_year,
				
				lat_degrees,
				lat_minutes,
				
				long_degrees,
				long_minutes,
				
				speed,
				course;
////////////////////////////////////////////////////////////////				
				



reg [7:0] 	fstate /* synthesis syn_encoding = "safe, one-hot" */;
localparam  COMMAND 			= 8'd0,
				UTC_Time 		= 8'd1,
				
				COMA				= 8'd2,
				GET_Veryf		= 8'd3,
				COMA_VER			= 8'd4,
				
				LATITUDE			= 8'd5,
				
				Wait				= 8'd6,
				N_S				= 8'd7,
				
				LONGITUDE		= 8'd8,
				
				Wait2				= 8'd9,
				E_W				= 8'd10,
					
				SPEED				= 8'd11,
				COMA_Course 	= 8'd12,
				COURSE			= 8'd13,
				
				COMMAND2			= 8'd14,
				
				Wait_Altitude	= 8'd15,  
				ALTITUDE			= 8'd16,
				
				COMA_DATE		= 8'd17,
				DATE				= 8'd18,
				
				Wait_CALENDAR	= 8'd19,
				FAULT_DATA		= 8'd20;


wire [7:0] 	comma, dot; 		assign comma = ","; 	assign dot 	= ".";
wire [7:0]	A;						assign A 	 = "A";
wire [47:0] GPGGA;				assign GPGGA = "GPGGA,";
wire [47:0] GNRMC;				assign GNRMC = "GNRMC,";
wire [47:0] GPRMC;				assign GPRMC = "GPRMC,";

reg  [3:0] 	digit;


always @ (posedge reset or posedge TIC) begin
	if (reset) begin
		fstate <= COMMAND;	
	//----------------------------//
		T_hour 			<= 16'b0;
		T_minutes 		<= 16'b0;
		T_seconds 		<= 16'b0;
		
		D_day 			<= 16'b0;
		D_month 			<= 16'b0;
		D_year 			<= 16'b0;
		
		lat_degrees 	<= 16'b0;
		lat_minutes 	<= 16'b0;
		
		long_degrees 	<= 16'b0;
		long_minutes 	<= 16'b0;
		
		speed 			<= 16'b0;
		altitude 		<= 32'b0;
		course 			<= 16'b0;
	//----------------------------//
		GPS_DATA			<= 224'b0;
		ERROR				<= 1'b0;
		digit <= 4'b0;
	end
	else begin
		case (fstate)
			COMMAND: begin
				digit  <= 4'b0;
				if ((ID == GNRMC) || (ID == GPRMC))begin // GNRMC or GPRMC <- look for this command
					fstate <= UTC_Time; 
					ERROR		<= 1'b0;
				//----------------------------//
					T_hour 			<= 16'b0;
					T_minutes 		<= 16'b0;
					T_seconds 		<= 16'b0;
				//----------------------------//	
	//GPS_DATA		<= {course,speed,altitude,longSec,longMin,latSec,latMin,utc_time};
					GPS_DATA		<= {
											 {altitude_L[7:0],	altitude_L[15:8]},
											 {altitude_H[7:0],	altitude_H[15:8]},
											 {speed[7:0],			speed[15:8]},
											 {course[7:0],			course[15:8]},
											 
											 {long_minutes[7:0],	long_minutes[15:8]},
											 {long_degrees[7:0],	long_degrees[15:8]},
											 
											 {lat_minutes[7:0],	lat_minutes[15:8]},
											 {lat_degrees[7:0],	lat_degrees[15:8]},									 
											 
											 {D_year[7:0],			D_year[15:8]},
											 {D_month[7:0],		D_month[15:8]},
											 {D_day[7:0],			D_day[15:8]},
											 
											 {T_seconds[7:0],		T_seconds[15:8]},
											 {T_minutes[7:0],		T_minutes[15:8]},
											 {T_hour[7:0],			T_hour[15:8]}
										};
				//----------------------------//
				end
				
				else fstate <= COMMAND;
				
			end
// get UTC ---------------------------------------------------	
			UTC_Time: begin 
			
				digit  <= digit + 4'b1;
				
				if (halfByte > 9) ERROR <= 1'b1;
				
				case (digit)
				
					0: T_hour [7:4] <= halfByte; 
					
					1: T_hour [3:0] <= halfByte;
					
					2: T_minutes [7:4] <= halfByte;
					
					3: T_minutes [3:0] <= halfByte; 
					
					4: T_seconds [7:4] <= halfByte;
					
					5: begin
						fstate <= COMA;						
						T_seconds [3:0] <= halfByte;
					end
					
				endcase
			end
			
			COMA: begin	
				digit 	<= 4'b0;
				if (byte == comma) fstate <= GET_Veryf;
			end			
			
			
			GET_Veryf: begin
				if (byte == A) begin
					fstate <= COMA_VER;
					digit  <= 4'b0;
//					D_day 			<= 16'b0;
//					D_month 			<= 16'b0;
//					D_year 			<= 16'h2000;
//					
//					lat_degrees 	<= 16'b0;
//					lat_minutes 	<= 16'b0;
//					
//					long_degrees 	<= 16'b0;
//					long_minutes 	<= 16'b0;
//					
//					speed 			<= 16'b0;
//					altitude 		<= 32'b0;
//					course 			<= 16'b0;
				end
				
				else 	fstate <= Wait_CALENDAR;		//	fstate <= COMMAND;
			end
			
			COMA_VER: if (byte == comma) begin
				digit  <= 4'b0;
				fstate <= LATITUDE;
				lat_degrees 	<= 16'b0;
				lat_minutes 	<= 16'b0;
			end
			
// get Latitude -----------------------------------------------			
			
			LATITUDE: begin
				digit  <= digit + 4'b1;
				
//				if ((halfByte > 9) && (halfByte != dot)) ERROR <= 1'b1;
				
				case (digit)
				
					0: lat_degrees [7:4]  <= halfByte; 
					
					1: lat_degrees [3:0]  <= halfByte;
					
					2: lat_minutes [15:12] <= halfByte;
					
					3: lat_minutes [11:8]  <= halfByte; 
					
					4: fstate <= LATITUDE;
					
					5: lat_minutes [7:4] <= halfByte; 
					
					6: begin
						fstate <= Wait;						
						lat_minutes [3:0] <= halfByte;
					end
					
				endcase
			end	
			
			Wait: begin
				digit  <= 4'b0;
				if (byte == comma) fstate <= N_S;				
			end
			
			N_S: begin				
				if 	  (byte == 8'h4e)lat_minutes[0] <= 1'b1;  // 'N'
				else if (byte == 8'h53)lat_minutes[0] <= 1'b0;	// 'S'	
				else if (byte == comma)begin
					digit  <= 4'b0;
					fstate <= LONGITUDE;
					
					long_degrees 	<= 16'b0;
					long_minutes 	<= 16'b0;
				end
			end
			
// get Longitude -----------------------------------------------

			LONGITUDE: begin
				digit  <= digit + 4'b1;
				
//				if (halfByte > 9) ERROR <= 1'b1;
				
				case (digit)
				
					0: long_degrees [11:8] <= halfByte;
					
					1: long_degrees [7:4]  <= halfByte; 
					
					2: long_degrees [3:0]  <= halfByte;
					
					3: long_minutes [15:12] <= halfByte;
					
					4: long_minutes [11:8]  <= halfByte; 
					
					5: fstate <= LONGITUDE;
					
					6: long_minutes [7:4] <= halfByte; 
					
					7: begin
						fstate <= Wait2;						
						long_minutes [3:0] <= halfByte;
					end					
				endcase
			end
			
			Wait2:begin
				digit  <= 4'b0;
				if (byte == comma) fstate <= E_W;
			end
			
			E_W: begin				
				if 	  (byte == 8'h45)long_minutes[0] <= 1'b1; // 'E'
				else if (byte == 8'h57)long_minutes[0] <= 1'b0; // 'W'	
				else if (byte == comma)begin				
					digit  	<= 4'b0;
					fstate 	<= SPEED;
					speed 	<= 16'b0;	
				end 
			end
// get Speed -----------------------------------------------		
			SPEED: begin
			
				if (byte == dot) begin
					fstate  <= COMA_Course;
				end
				
				else begin
					speed 		<= speed << 4;
					speed [3:0] <= halfByte;
				
					if (halfByte > 9) ERROR <= 1'b1;
				
				end
				
			end
			
			COMA_Course : if (byte == comma) begin
				fstate 	<= COURSE;
				course 	<= 16'b0;
			end
			
// get Course -----------------------------------------------		
			COURSE: begin
				if (byte == dot) 		fstate <= COMA_DATE;	//COMMAND
				
				else begin
					course 		 <= course << 4;
					course [3:0] <= halfByte;
				
					if (halfByte > 9) ERROR <= 1'b1;
				
				end
			end	
			
			COMA_DATE: if (byte == comma) begin
				digit  	<= 4'b0;
				fstate 	<= DATE;
				D_day 	<= 16'b0;
				D_month 	<= 16'b0;
				D_year 	<= 16'h2000;
			end
			
			
// get DATE -----------------------------------------------			
			DATE: begin 
			
				digit  <= digit + 4'b1;
				
				if (halfByte > 9) ERROR <= 1'b1;
								
				case (digit)
					
					0: D_day [7:4] 	<= halfByte; 
					
					1: D_day [3:0] 	<= halfByte;
					
					2: D_month [7:4] 	<= halfByte;
					
					3: D_month [3:0] 	<= halfByte; 
					
					4: D_year [7:4] 	<= halfByte;
					
					5: begin
						fstate <= COMMAND2;						
						D_year [3:0] <= halfByte;
					end
					
				endcase
			end
//=============================================================================== END of GPRMC			
			
			COMMAND2: begin
			
				digit 	<= 4'b1;
				
				if (ID == GPGGA) begin // GPGGA
					fstate 	<= Wait_Altitude;
				end
			end
			
			Wait_Altitude: begin		
			
				if (byte == comma)begin
					digit <= digit + 4'b1;
					if (digit == 8)begin
						fstate 	<= ALTITUDE;
						altitude <= 32'b0;
					end
				end
				
			end
			
			ALTITUDE:begin
			
				if (byte == dot) fstate <= COMMAND;
				
				else begin
					altitude 		<= altitude << 4;
					altitude [3:0] <= halfByte;
				
					if (halfByte > 9) ERROR <= 1'b1;
				
				end
				
			end
			
			
			Wait_CALENDAR: begin		
			 
				if (byte == comma)begin
					
					if (digit == 6)begin
						fstate 	<= FAULT_DATA;
						digit 	<= 4'b0;
					end
					
					else digit <= digit + 4'b1;
				end
				
			end
			
			FAULT_DATA: begin 
			 
				digit  <= digit + 4'b1;
				
				if (halfByte > 9) ERROR <= 1'b1;
								
				case (digit)
					
					0: D_day [7:4] 	<= halfByte; 
					
					1: D_day [3:0] 	<= halfByte;
					
					2: D_month [7:4] 	<= halfByte;
					
					3: D_month [3:0] 	<= halfByte; 
					
					4: D_year [7:4] 	<= halfByte;
					
					5: begin
						fstate <= COMMAND;						
						D_year [3:0] <= halfByte;
					end
					
				endcase
			end
			
		endcase
	end
end

endmodule