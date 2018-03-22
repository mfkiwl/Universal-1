/*

wire [15:0] ________;

TAHO 
TAHO_Unit
(
	 .clock		(clk_1MHz),
	 .reset		(reset),
	 .sec			(sec),	 
	 .taho		(TAHO1),	 
	 .freq		(______)
);
*/


module TAHO(
	 clock,		// clk_1MHz
	 reset,
	 sec,
	 
	 taho,
	 
	 freq
);

input wire clock, reset, sec, taho;
 
output reg [15:0] freq;


wire TAHO_sync;

Sync_input 
Sync_TAHO(
	 .clock			(clock),
	 .signal			(taho),
	 .signal_sync	(TAHO_sync)
);

/*
	NEW taho counter
*/

reg [2:0] st;

always @ (posedge reset or posedge clock) begin
	if (reset) begin
		freq <= 16'b0;
		st		<= IDDLE;
	end	
	
	else begin
		case (st)
		 
			IDDLE: 	if (sec) 	st <= POSITIV;
			
			POSITIV: begin
				freq 	<= t_cnt;
				st		<= NEGATIV;
			end
			
			NEGATIV: if (~sec) 	st <= IDDLE;
			
		endcase
	end
end
//--------------------------------------------------------------------------------------------------------//
localparam 	IDDLE		= 3'b000,
				POSITIV	= 3'b001,
				NEGATIV	= 3'b010,
				WT_sec	= 3'b011,
				FILTR		= 3'b100,
				FILTR2	= 3'b101;

reg [16:0] t_cnt,cnt;
reg [2:0]  state;

always @ (posedge reset or posedge clock) begin
	if (reset) begin
		
		t_cnt		<= 16'b0;
		cnt		<= 16'b0;
		state		<= IDDLE;
		
	end
	
	else begin
		case (state)
		 
			IDDLE: begin				
				
				if (sec) 				state <= WT_sec;		
				else if (TAHO_sync) 	state <= FILTR;		
				else 						state <= IDDLE;	
				
			end
			
			FILTR: begin 
				
				if (cnt == 78) begin
					state 	<= FILTR2;
					cnt	 	<= 16'b0;
				end
				else cnt <= cnt + 16'b1;
				
			end
			
			FILTR2: begin 
				
				if (TAHO_sync) 	state <= POSITIV;
				else 					state <= IDDLE;
				
			end
			
			POSITIV: begin
			 
				t_cnt		<= t_cnt + 16'b1;
				state 	<= NEGATIV;			
				
			end
			
			NEGATIV: begin
			 
				if (sec) 				state 	<= WT_sec;
				else if (~TAHO_sync) state 	<= IDDLE;
				else 						state 	<= NEGATIV;
				
			end
			
			WT_sec: begin			
			 
				if (~sec) begin
					t_cnt	<= 16'b0;
					state	<= IDDLE;
				end
				else 	state <= WT_sec;
				
			end
		endcase
	end
end

endmodule