/*
Sync_input Sync_input_NAME(
	.clock			(),
	.signal			(),
	.signal_sync	()
);
*/

module Sync_input (
clock,
signal,
signal_sync
);

input		wire clock, signal;
output	wire signal_sync; 	


assign signal_sync = sync[1];
reg [1:0] sync;

always @(posedge clock) sync <= { sync[0], signal };


endmodule