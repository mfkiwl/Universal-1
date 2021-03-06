/*

wire [15:0] imp;

IMPULS 
IMPULS_Unit
(
	 .clock		(clk_1MHz),
	 .reset		(reset),
	 .msec		(msec),	 
	 .impuls		(impuls),	 
	 .imp			(imp)
);
*/


module IMPULS(
	 clock,		// clk_1MHz
	 reset,
	 msec,
	 
	 impuls,
	 
	 imp
);	

input wire clock, reset, msec, impuls;
 
output reg [15:0] imp;


wire impuls_sync;

Sync_input 
Sync_impuls(
	 .clock			(clock),
	 .signal			(impuls),
	 .signal_sync	(impuls_sync)
);

reg [4:0] msec_cnt;

reg [1:0] state;

localparam 	iddle		= 2'b00,
				cntH		= 2'b01,
				cntL		= 2'b10,
				decision	= 2'b11;
				
				
always @ (posedge clock or posedge reset) begin

	if (reset) begin
		imp		<= 16'b0;
		msec_cnt <= 5'b0;
		state 	<= iddle;
	end
	
	else begin
		case (state)
			iddle:begin
				if (impuls_sync) begin
					imp	<= 16'hffff;
					state	<= cntH;
				end
				else begin
					state <= iddle;
					imp		<= 16'b0;
					msec_cnt <= 5'b0;
				end
			end
			
			cntH: begin
				if (msec) begin
					msec_cnt <= msec_cnt + 5'b1;
					state 	<= decision;
				end
			end
			
			cntL: if (~msec)	state <= cntH;
			
			decision: begin
				if (msec_cnt == 18) 	state 	<= iddle;
				else 					 	state 	<= cntL;
			end
		endcase
	end 
end


endmodule