/*

wire rd_ena;
wire [B-1:0] r_data;

wr_fifo 
My_fifo
(
	.clk		(clock),
	.reset		(reset),
	.aclr		(aclr),	
	
	.wr 		(wrreq),
	.w_data		(data),
	
	.rd_ena		(rd_ena),
	.r_data		(r_data)
);
*/


module wr_fifo 
#(
	parameter 	B = 8,
				W = 2
)
(
input wire clk, reset, wr_in, aclr,
input wire 	[7:0] w_data,
output wire [7:0] r_data,
output wire rd_ena
);

// s i g n a l d e c l a r a t i o n
reg [7:0] array_reg [3:0] ; // r e g i s t e r a r r a y
reg [4:0] w_ptr_reg, 	w_ptr_next , w_ptr_succ;

reg wr_ena;
always @ (posedge clk) 
	if (reset) 
		wr_ena <= 1'b0;
	else if (w_data == 8'hff)
		wr_ena <= 1'b1;

wire wr = wr_ena ? wr_in : 1'b0;		

reg  ful_reg, full_next;
// output 
wire ful; assign ful  = ful_reg & ~aclr;

assign rd_ena = ful ? wr : 1'b0;

// body
// reg file write operation
always@(posedge clk) begin
    case ({aclr,wr})
		2'b10: begin
		   array_reg[0] <= 0;
		   array_reg[1] <= 0;
		   array_reg[2] <= 0;
		   array_reg[3] <= 0;
		end
		2'b01:  begin
		   array_reg[0] <= w_data;
		   array_reg[1] <= array_reg[0];
		   array_reg[2] <= array_reg[1];
		   array_reg[3] <= array_reg[2];
		end
	endcase
end

// reg file read operation
assign r_data = array_reg [3];


//fifo control logic
// regs for read and write pointers
always@ (posedge clk, posedge reset)
	if(reset) begin
		w_ptr_reg 	<= 0;
		ful_reg		<= 1'b0;
	end
	
	else begin
		w_ptr_reg 	<= w_ptr_next;
		ful_reg		<= full_next;
	end

// next-state logic for read and write pointers	
always @* begin
	
	w_ptr_succ = w_ptr_reg + 1;	// succesive pointer values
	
	w_ptr_next = w_ptr_reg; 	// default: keep old values
	
	full_next = ful_reg;
	
	case ({aclr,wr})
	
		// 2'b00 : no operation
		
		2'b10: begin // clear	
		
			w_ptr_next	= 0;
			full_next	= 1'b0;
			
		end	
			
		2'b01: begin// write	
		
			w_ptr_next = w_ptr_succ;
			
			if (w_ptr_succ == 4)
				full_next = 1'b1;
				
		end		
		
	endcase
end





endmodule