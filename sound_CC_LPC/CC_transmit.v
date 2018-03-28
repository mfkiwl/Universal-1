//`ifndef SUBFRAME_D
//  `include "defines.vh";
//`endif 
/*
CC_transmit CC_transmitUnit(
	 .reset				(reset),
	 .clock				(clock),
	 
	 .RDY					(RDY),	
	 
	 .rdaddress			(CC_rd),			// [10:0]
	 .data				(CC_data),		//[7:0]
	 
	 .tx					(CC_tx)
);
*/



module CC_transmit(
	reset,
	clock,
	
	RDY,			// [3:0]	
	
	rdaddress,		// [13:0]
	data,			// [7:0]
	
	tx
);	

input wire reset, clock;

input wire 			RDY;

output reg [11:0] rdaddress;
input wire [7:0] 	data;

output reg 	tx;
 
`ifdef	CFDR	// look in "defines.vh"
	parameter SUBFRAME = 2048;
`else 
	parameter SUBFRAME = 48;
`endif	

	parameter delay_val = 48;	
//--------------------------//


	reg [2:0]	BIT;
	reg [7:0] 	delay, BUFF;
	reg [12:0]  bytes_sent;
	
	reg [2:0] 	state/* synthesis syn_encoding = "safe, one-hot" */;
	
localparam 		Idle				= 3'b000,
					TODO				= 3'b001,
					Start				= 3'b010,
					Trans				= 3'b011,
					Delay				= 3'b100,
					NEXT_stp			= 3'b101,
					STOP				= 3'b110;
	
always @ (posedge reset or posedge clock) begin
	if (reset) begin
		tx 			<= 1'b1;	
		
		BIT 			<= 3'd0;
		BUFF			<= 8'b0;	
		
		bytes_sent	<= 13'b0;
		
		rdaddress	<= 12'b0;
		delay 		<= 8'b0;	
		
		state			<= Idle;		
	end
	
	else begin
		case (state) 
			
			Idle: begin				
				
				tx 			<= 1'b1;	
				
				BIT 			<= 3'd0;
				BUFF			<= 8'b0;	
				
				bytes_sent	<= 13'b0;
				rdaddress	<= 12'b0;
				delay 		<= 8'b0;	
				
				if (RDY) 		state <= TODO;
				else 				state <= Idle;
				
			end
			
			TODO: begin
			 
				if (bytes_sent == SUBFRAME) begin 
					state			<= Idle;
					
					tx 			<= 1'b1;
					bytes_sent	<= 13'b0;
			
				end
				
				else begin
				//---------------------------------------
					tx 			<= 1'b0;
					state		<= Start;
					BUFF		<= data;
					rdaddress	<= rdaddress + 12'b1;
					bytes_sent	<= bytes_sent + 13'b1;
				//---------------------------------------
				end
			 
			end
			
			Start: begin
			 
				tx <= 1'b0;
				
				if (delay == delay_val) begin
				 
					delay 		<= 8'b0;
					state		<= Trans;
					
				end
				
				else delay <= delay + 8'b1;
				
			end
			
			Trans: begin
			 
				tx 		<= BUFF[BIT];
				BIT		<= BIT + 3'b1;
				state	<= Delay;
				
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
					state	<= TODO;
					
				end
				
				else delay <= delay + 8'b1;
			 
			end
				
		endcase
	end
end


endmodule