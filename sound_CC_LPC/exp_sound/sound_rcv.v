/*
sound_rcv 
four_ch_sound
(
	 .clk			(clock),
	 .rst			(reset),
	 .rx			(aud1),
	 .msec		(msec),
	 .start		(timer),
	 .rdaddress	(rd_SOUND),
	 .q			(s_data)	
);	
*/

module sound_rcv (

input wire clk, rst, rx, msec, start,

input  wire 	[8:0]  	rdaddress,
output wire		[31:0]	q
);





wire s_tick;

mod_m_timer 
#(.N(4),.M(3))
sound_uart_timer(
	 .clk		(clk),
	 .rst		(rst),
	 .tick	(s_tick)
);



uart_rx 
sound_rx(
	 .clk(clk),
	 .rst(rst),
	 .rx(rx),
	 .s_tick(s_tick),
	 .rx_done_tick(rx_done_tick),
	 .dout(dout)
);

wire [ 7:0] dout;
wire rx_done_tick;



//
//buff_ram 
//topchik
//(
//	.clk(clk), 
//	.reset(rst), 
//	.msec(msec), 
//	.timer(start), 
//	.rx_done_tick(rx_done_tick),
//	.dout(dout),
//	
//	.rd_sound(rdaddress),
//	.q_sound(q)
//);
//
//

//	
//wire rd_ena;
//wire [7:0] r_data;
//
//wr_fifo 
//My_fifo
//(
//	.clk			(clk),
//	.reset		(rst),
//	.aclr			(aclr_n),	
//	
//	.wr_in		(rx_done_tick),
//	.w_data		(dout),
//	
//	.rd_ena		(rd_ena),
//	.r_data		(r_data)
//);
//
//reg [10:0] wraddress;
//reg [2:0]	flush;
//reg aclr_n;
//always @(posedge clk) begin
//	if (rst)begin
//		flush	 	 <= 3'b0;
//		aclr_n 	 <= 1'b0;
//		wraddress <= 10'b0;
//	end
//	else begin
//		casex ({start, aclr, rd_ena})
//		 
//			3'b0xx: begin
//				wraddress <= 10'b0;
//				flush		 <= 3'b0;
//			end
//			
//			3'b100: begin
//				aclr_n	<= 1'b0;
//				if (wraddress == 2000) begin
//					flush		 <= flush + 3'b1;
//					wraddress <= 10'b0;
//				end
//			end
//			
//			3'b101: 
//				wraddress <= wraddress + 10'b1;
//			
//			3'b110:
//				if (flush[2]) begin
//					flush	 <= 3'b0;
//					aclr_n <= 1'b1;
//				end
//				
////			3'b111:			
//		 
//		endcase	
//	end
//end
//
//
//s_Buff4 s_BuffUnit(
//	 .clock			(clk),
//	 .data			(r_data),		// [7:0] 
//	 .rdaddress		(rdaddress),	// [8:0]
//	 .wraddress		(wraddress),	// [10:0]
//	 .wren			(rd_ena),
//	 .q				(q)				// [15:0]
//);

endmodule