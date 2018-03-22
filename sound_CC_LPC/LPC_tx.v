/*


LPC_tx LPC_txUnit(
	 .reset				(reset),
	 .clock				(clock),
	 
	 .buff_RDY			(buff_RDY),		// [3:0]
	 .packet_SENT		(packet_SENT),
	 
	 .rdaddress			(rdaddress),	// [13:0]
	 .data				(q),				//[7:0]
	 
	 .LPC_bsy			(LPC_bsy),
	 .tx					(Tx_sound)
);

*/

module LPC_tx(
	reset,
	clock,
	
	buff_RDY,		// [3:0]
	packet_SENT,
	
	
	rdaddress,		// [13:0]
	data,				// [7:0]
	
	LPC_bsy,
	tx,
	real_pack
);	

input wire reset, clock, LPC_bsy;

input wire [3:0] buff_RDY;
input wire [7:0] data;

output reg 	tx;
output reg 	packet_SENT;
output reg [14:0] rdaddress;
output reg [11:0] real_pack;
 

   parameter delay_val = 48;	
//--------------------------//



	reg [2:0]	BIT;
	reg [7:0] 	delay, BUFF;
	reg [12:0]  bytes_sent;
	
	reg [3:0] 	state/* synthesis syn_encoding = "safe, one-hot" */;
	
	localparam 	Idle				= 4'b0000,
					Trans				= 4'b0001,
					Delay				= 4'b0010,
					Start				= 4'b0011,
					STOP				= 4'b0100,
					WAIT_BSY			= 4'b0101,
					VERIFY_BSY		= 4'b0110,
					TODO				= 4'b0111,
					WAIT_START  	= 4'b1000,
					WAIT_BSY_Idle	= 4'b1001,
					NEXT_stp			= 4'b1010;
	
always @ (posedge reset or posedge clock) begin
	if (reset) begin
		tx 			<= 1'b1;	
		
		BIT 			<= 3'd0;
		BUFF			<= 8'b0;	
		
		bytes_sent	<= 13'b0;
		real_pack	<= 12'b0;
		
		rdaddress	<= 15'b0;
		packet_SENT	<= 1'b0;
		delay 		<= 8'b0;	
		real_pack	<= 12'b0;
		
		state			<= Idle;		
	end
	
	else begin
		case (state) 
			
			Idle: begin				
				
				tx 			<= 1'b1;	
				
				BIT 			<= 3'd0;
				BUFF			<= 8'b0;	
				
				bytes_sent	<= 13'b0;
				real_pack	<= 12'b0;
				
				packet_SENT	<= 1'b0;
				delay 		<= 8'b0;	
				real_pack	<= 12'b0;
				
				if (buff_RDY) 	state <= TODO;
				else 				state <= Idle;
				
			end
			
			TODO: begin
			 
				if (bytes_sent == 2048) begin
					state			<= WAIT_BSY_Idle;
					packet_SENT	<= 1'b1;
					
					tx 			<= 1'b1;
					bytes_sent	<= 13'b0;
			
//					BUFF	<= BUFF + 8'd1;		
				end
				
				else begin
				//---------------------------------------
					tx 			<= 1'b0;
					state			<= Start;
					BUFF			<= data;
//				// ===>	BUFF			<= BUFF + 8'd1;
					rdaddress	<= rdaddress + 15'b1;
					bytes_sent	<= bytes_sent + 13'b1;	
					real_pack	<= real_pack + 12'b1;
				//---------------------------------------
				end
			 
			end
			
			Start: begin
			 
				tx <= 1'b0;
				
				if (delay == delay_val) begin
				 
					delay 		<= 8'b0;
					state			<= Trans;
					
				end
				
				else delay <= delay + 8'b1;
				
			end
			
			Trans: begin
			 
				tx 		<= BUFF[BIT];
				BIT		<= BIT + 3'b1;
				state		<= Delay;
				
			end
			
			Delay: begin
			 
				if (delay == delay_val) begin
				 
					delay <= 8'b0;	
					state <= NEXT_stp;			
				 
				end				
				
				else  delay <= delay + 8'b1;
				
			end
			
			NEXT_stp: begin
			 
				if (BIT == 0) begin
					tx 		<= 1'b1;
					state  	<= STOP;	
				end
				
				else state <= Trans;
				
			end
			
			STOP: begin
			 	
				if (delay == delay_val + delay_val)begin
				 
					delay 	<= 8'b0;
					state		<= TODO;
					
				end
				
				else delay <= delay + 8'b1;
			 
			end

			WAIT_BSY_Idle: begin
				packet_SENT	<= 1'b0;
//				state	<= Idle;
				
				if (LPC_bsy) 	state	<= WAIT_BSY;
				else 				state	<= WAIT_BSY_Idle;
			end
			
			WAIT_BSY: begin				
				if (~LPC_bsy) begin
					state	<= Idle;	 
				end
				else 					state	<= WAIT_BSY;
			end
				
		endcase
	end
end


endmodule