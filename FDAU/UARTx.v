/*


wire [15:0] DATA;
wire 			ENA;	
	
wire			busy;
output reg 			tx;

UARTx  
		 #(.trans_mode(1),	
			.delay_val(FAST_clk))
DATA_STREAM (
	 .clock		(clock),
	 .reset		(reset),	
	 .busy		(busy),	
	 .DATA		(SEND_pack),
	 .ENA			(SEND_start),	
	 .tx			(TX)
);
*/

/*
parameter FAST_clk = 48, SLOW_clk =217;
*/

module	UARTx #(parameter 	trans_mode 	= 1,
										delay_val	= 48)
(
	 clock,
	 reset,
	
	 busy,
	
	 DATA,
	 ENA,
	
	 tx
);


input wire 			clock;
input wire 			reset;
	
output reg 			busy;

input wire [15:0] DATA;
input wire 			ENA;

output reg 			tx;




wire [7:0] data1, data2;
	assign data1 = DATA[7:0];
	assign data2 = DATA[15:8];
	
///*----------------------------------------------------------
//	making tact impulses by delaying on current UART standart 
//	delay = clock / 2 * UART fr
//	50 000 000 / (2 * 115 200) = 217 
//	
//	'clock' 	= 50 Mhz
//	'clk'		= 115200 Hz
//-----------------------------------------------------------*/
//
//	wire [15:0] cycle;	assign cycle = clock_mode ? 2 : 86;	//	49:217 for 50MHz
///*
//if clock_mode = '1' then mClock = f_clk 			<= trans to EBN @ 1 MHz
//if clock_mode = '0' then mClock = s_clk			<= trans to LPC @ 115200
//*/
//
//reg clk;
//reg [15:0] delay; 
//
//always @ (posedge reset or posedge clock)  begin	
//	if (reset) begin	
//		clk <= 1'b0;
//		delay <= 16'b0;
//	end
//	else  begin 	
//		delay <= delay +16'b1;
//		if (delay == cycle) begin	
//			clk <= ~clk;
//			delay <= 0;
//		end
//	end
//end

//=============================================================

reg [7:0] 	delay;
reg [15:0] 	BUFF;
reg [3:0] 	BIT;

reg [2:0] 	state/* synthesis syn_encoding = "safe, one-hot" */;

localparam 	IDLE 			= 3'b000,
				START			= 3'b001,
				TRANSMIT		= 3'b010,
				DELAY			= 3'b011,
				NEXT_stp		= 3'b100,
				STOP			= 3'b101,
				_16Bit		= 3'b110;

always @ (posedge reset or posedge clock)begin
	if (reset) begin
		tx			<= 1'b1;
		busy		<= 1'b0;
		BIT 		<= 4'b0;					
		BUFF 		<= 16'b0;
		state		<= IDLE;
	end
	else begin
		case (state)
			
			IDLE: begin
			 
				if (ENA) begin				
					tx 		<= 1'b0;
					busy		<= 1'b1;
					BIT 		<= 3'd0;
					BUFF  	<= {data2,data1};
					state 	<= START;
				end
				
				else   begin
					tx			<= 1'b1;
					busy		<= 1'b0;
					BIT 		<= 3'b0;					
//					BUFF 		<= 16'b0;
					state		<= IDLE;
				end
				
			end	
			
			START: begin
			 
				tx <= 1'b0;
				
				if (delay == delay_val) begin
				 
					delay 	<= 8'b0;
					state		<= TRANSMIT;
					
				end
				
				else delay <= delay + 8'b1;
				
			end
			
			TRANSMIT: begin
			 
				tx 		<= BUFF[BIT];
				BIT		<= BIT + 4'b1;
				state	<= DELAY;
				
			end
			
			DELAY: begin
			 
				if (delay == delay_val) begin
				 
					delay <= 8'b0;	
					state <= NEXT_stp;			
				 
				end				
				
				else  delay <= delay + 8'b1;
				
			end
			
			NEXT_stp: begin
			 
				if ((BIT == 0)||(BIT == 8)) begin
					tx 		<= 1'b1;
					state  	<= STOP;	
				end
				
				else state <= TRANSMIT;
				
			end
			
			STOP: begin
			 	
				if (delay == delay_val + delay_val)begin
				 
					delay 	<= 8'b0;
					state		<= _16Bit;
					
				end
				
				else delay <= delay + 8'b1;
			 
			end
			
			_16Bit: begin
				if (BIT == 0)begin
					busy		<= 1'b0;
					state		<= IDLE;
				end
				else state 	<= START;
			end	
	    
		endcase
	end
end

endmodule