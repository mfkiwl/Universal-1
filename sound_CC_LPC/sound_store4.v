/*

defparam sound_storeUnit2.length = 45;
defparam sound_storeUnit2.middle = 22;

wire [10:0] s2_rdaddress;
wire [7:0]	s2_data;

sound_store4 sound_storeUnit(
	 .reset			(reset),
	 .rst				(frame),
	 .clock			(clock),
	  
	 .Rx					(CH_34),
	 .bytes_written	(bytes_written),		// [13:0]	
	 .rdaddress			(s2_rdaddress),		// [8:0]
	 .q					(s2_data)				//	[7:0]	
);

*/

module sound_store4 #(parameter length = 48, middle = 22)
(
	reset,
	rst,
	clock,
	
	Rx,
	
	bytes_written,
	rdaddress,
	q
);
	
input wire 	reset, rst, clock;

input wire 	Rx;

output reg 		[13:0] 	bytes_written;
input  wire 	[8:0]  	rdaddress;
output wire		[31:0]	q;
	
	
	
	
	 reg 			word, wren;
	 reg [5:0]  bit_length;
	 reg [2:0]  bit;
	 reg [7:0]	r_byte;
	 reg [15:0] data;
	 reg [9:0] wraddress;
	
	
	
reg [2:0] state/* synthesis syn_encoding = "safe, one-hot" */;

localparam 	IDDLE			= 3'b000,
				DATA_BYTE	= 3'b001,
				SAMPLE		= 3'b010,
				STOP 			= 3'b011,
				PRE_STOP 	= 3'b100;

	
	
always @ (posedge reset or posedge rst or posedge clock )begin

	if (reset) begin
	
		state 		<= SAMPLE;
		bit_length 	<= 6'b0;	
		bit 			<= 3'b0;	
		r_byte		<= 8'b0;
		data 			<= 16'b0;
		
		word 			<= 1'b0;
		wren			<= 1'b0;
		wraddress	<= 10'b0;
		bytes_written  <= 14'b0;	
		
	end	
	
	else if (rst) begin
		wraddress		<= 10'b0;
		bytes_written  <= 14'b0;	
		//data 				<= 16'b0;
	end
	
	else begin
	 
		case (state)
		 
			SAMPLE: begin
				
				bit_length 	<= 6'b0;
				
				if (~Rx) state <= IDDLE;
				
				else  	state <= SAMPLE;
				
			end	
			
			IDDLE: begin
				
				if (Rx)  state <= SAMPLE;
				
				else begin
				 
					if (bit_length == middle) begin
				    
						bit_length	<= 6'b0;
						state 		<= DATA_BYTE;
						
					end
					
					else begin
						state 		<= IDDLE;
						bit_length 	<= bit_length + 6'b1;
					end
					
				end
				
			end

			DATA_BYTE: begin	
			 
				if (bit_length == length) begin
				 
					r_byte [bit] 	<= Rx; 
					bit_length 		<= 6'b0;
					
					if (bit == 7) begin
						word	<= ~ word;
						bit 	<= 3'b0;
						state <= PRE_STOP;
					end
					
					else begin
						bit 	<= bit + 3'b1;
						state <= DATA_BYTE;
					end
					
				end
				
				else bit_length <= bit_length + 6'b1;
				
			end
			
			
			PRE_STOP: begin
			 
				state 			<= STOP;
				bytes_written 	<= bytes_written + 1'b1;
				wren				<= 1'b1;
				case (word) 
					
					0:begin
						data[7:0] <= r_byte;
					end
					
					1: begin
						data[15:8] <= r_byte;
					end
					
				endcase
				
			end

			STOP: begin 
			 
				if (bit_length == middle) begin
				 
					bit_length 	<= 6'b0;	
					state 		<= SAMPLE;
					
					if (word) wraddress	<= wraddress + 10'b1;
					
				end
				
				else begin
					state 		<= STOP;
					bit_length 	<= bit_length + 6'b1;
				end
				
			end
			
		endcase
	end
end	


s_Buff4 s_BuffUnit(
	 .clock			(clock),
	 .data			(data),			// [15:0] 
	 .rdaddress		(rdaddress),	// [8:0]
	 .wraddress		(wraddress),	// [8:0]
	 .wren			(wren),
	 .q				(q)				// [15:0]
);

endmodule