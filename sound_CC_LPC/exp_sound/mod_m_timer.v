`timescale 1ns / 1ps
/*

wire tick;

mod_m_timer 
#(.N(),.M())
sound_uart_timer(
	 .clk	(clk),
	 .rst	(rst),
	 .tick	(tick)
);

*/
module mod_m_timer
	#(
		parameter 	N=4, // number of bits in timer counter
					M=10 // mod-M
	)
	(
		input wire clk, rst,
		output wire tick
    );

	reg  [N-1:0] counter;
	wire [N-1:0] counter_next;
	
	always @(posedge clk, posedge rst)
		if (rst)
			counter <= 0;
		else
			counter <= counter_next;
			
			
	assign counter_next = (counter == (M-1)) ? 0 : counter + 1;
	
	assign tick = (counter == (M-1)) ? 1'b1 : 1'b0;
	
endmodule