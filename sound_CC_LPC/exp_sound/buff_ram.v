/*
buff_ram 
topchik
(
	.clk(clk), 
	.reset(rst), 
	.msec(msec), 
	.timer(start), 
	.rx_done_tick(rx_done_tick),
	.dout(dout),
	
	.rd_sound(rdaddress),
	.q_sound(q)
);

*/



module buff_ram
#(
	parameter 	B = 8,	
					W = 2
)
(
input wire clk, reset, msec, timer, rx_done_tick,
input wire [7:0] dout,

input  wire 	[8:0]  	rd_sound,
output wire		[31:0]	q_sound

);


wire fr;

pos_edge_det 
pos_edge_det_UNIT
( 
	 .sig		(msec),
	 .clk		(clock),
	 .pe		(fr)
);

// s i g n a l d e c l a r a t i o n
reg [B-1:0] array_reg [3:0] ;//[2**W-1:0] ; // r e g i s t e r a r r a y
reg [W:0] 	w_ptr_reg, w_ptr_next; 	
reg [W:0] 	w_ptr_succ;


reg	  wren, wren_n;
reg	[8:0]  wraddress;

	
wire full; assign full = w_ptr_succ[W];

// write enable only if FIFO is not full
wire wr; assign wr = rx_done_tick & timer;

// body
// reg file write operation
always @ (posedge clk)
	if (wr)
		array_reg[w_ptr_reg] <= dout;

		
always @ (posedge clk) begin
	if (fr)
		wraddress <= 9'b0;
		
	else begin
		if (wren)
			wraddress <= wraddress + 9'b1;		
	end
end


always@ (posedge clk, posedge reset)
	if(reset) 
		w_ptr_reg 	<= 0;	
		
	else begin
		wren			<= wren_n;
		w_ptr_reg 	<= w_ptr_next;
	end
	
	
	
always @* begin

	wren_n		= 1'b0;
	
	w_ptr_succ = w_ptr_reg + 1;
	
	w_ptr_next = w_ptr_reg;	
	
	casex({fr,wr,full})
		
		3'b010:
			w_ptr_next = w_ptr_succ;
		
		3'b001: begin
			wren_n		= 1'b1;
			w_ptr_succ	= 0;
			w_ptr_next	= 0;
		end	
		
		3'b1xx: begin
		
		end
			
	endcase
end
	
		
		
		
		
wire [31:0] data;	assign data = {array_reg[3],array_reg[2],array_reg[1],array_reg[0]};



sound_ram_fifo 
four_sounds(
	.clock		(clk),
	.data		(data),
	.rdaddress	(rd_sound),
	.wraddress	(wraddress),
	.wren		(wren),
	.q			(q_sound)
);

endmodule