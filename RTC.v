/*
	PLL & RTC
*/
/*		<==========

wire 	reset,
		msec,
		sec,
		delay,
		LED,
		clk_5Mhz,
		clk_1MHz, 
		clk_10MHz,
		clk_400kHz;

RTC 
RTCUnit
(	 
	 .mclock		(inp_clk),		
	 .reset		(reset),		
	 .SYNC		(SYNC),
	 
	 .msec		(msec),			
	 .sec			(sec),			
	 .delay		(delay)	
	 
	 .LED_FPGA	(LED),
	 
	 .clk_5Mhz		(clk_5Mhz),
	 .clk_1MHz		(clk_1MHz),
	 .clk_10MHz		(clk_10MHz),
	 .clk_400kHz	(clk_400kHz)
);	

*/

module RTC (
 	 mclock,
	 reset,
	 SYNC,
	 
	 msec,
	 sec,
	 delay,
	 
	 LED_FPGA,
	 
	 clk_5Mhz,
	 clk_1MHz,
	 clk_10MHz,
	 clk_400kHz
	);

input	wire 	mclock,
				SYNC;

output wire clk_5Mhz,
				clk_1MHz,
				clk_10MHz,
				clk_400kHz;


output reg 	reset,
				msec,
				sec,
				delay;

output reg 	LED_FPGA;


`ifdef USE_SYNC
	parameter synchro = 1;
`else 
	parameter synchro = 0;
`endif


parameter 	secs_delay 	= 10, 
				clk_persec 	= 400_000,	// main clk for SEC & MSEC
				every_sec	= 25_000, 	// clk_persec/every_sec = 400_000 / 25_000 = 16
				delay_low	= 3;		// clocks per HIGH SEC & MSEC
			
			
/*
	PLL
*/

CLK 
CLOCK( 
	 .inclk0		(mclock),
	 .c0			(clk_5Mhz),
	 .c1			(clk_1MHz),
	 .c2			(clk_10MHz),
	 .c3			(clk_400kHz)
);

/*
	 global	RESET
*/
reg [9:0]	counter;

always @ (posedge mclock) begin
	reset <= 1'b1;
	counter <= counter + 10'b1;
	
	if (counter == 1000) begin
		counter <= counter;
		reset <= 1'b0;
	end
	
end	
//--------------------------------------------//


/*
	 One seccond counter
*/	
	reg [31:0] clk_cnt;
	
always @ (posedge clk_400kHz or posedge reset) begin

	if (reset) begin
		clk_cnt 	<= 32'b1;
		sec 		<= 1'b0;
		
	end
	
	else begin
	 
		if (clk_cnt == clk_persec) begin
		 
			sec 		<= 1'b1;
			clk_cnt 	<= 32'b1;			
			
		end
		
		else begin
		
			if (clk_cnt  == delay_low) sec 	<= 1'b0;
			
			clk_cnt 	<= clk_cnt  + 32'b1;
		end
		
	end
end
//--------------------------------------------//


/*
	 Delay up to 255 secs
*/
reg [7:0] timer_cnt;

always @ (posedge sec or posedge reset) begin

	if (reset) begin
		delay 		<= 1'b0;
		timer_cnt	<= 8'b0;
	end
	
	else begin		
		if (timer_cnt == secs_delay)begin
			delay 		<= 1'b1;	
			timer_cnt	<= timer_cnt;
		end
		
		else timer_cnt	<= timer_cnt + 8'b1;
	end
end	



/*
	 Fraction of a seccond in details
*/
reg [31:0] msec_cnt;

always @ (posedge clk_400kHz or posedge reset) begin
	if (reset) begin
		msec			<= 1'b0;
		msec_cnt 	<= 32'b1;
	end
	
	else begin
	 	case (delay) 
		 
			1: begin
				if (msec_cnt == every_sec)begin
					msec 			<= 1'b1;
					msec_cnt 	<= 32'b1;
				end
				
				else begin
				 
					if (msec_cnt == delay_low) msec 	<= 1'b0;
					
					msec_cnt <= msec_cnt + 32'b1;
				end
			end
			
			0: begin
				msec		<= 1'b0;
				msec_cnt <= 32'b1;
			end
			
		endcase
	end
end



/*
	Module for blinking LED from all FPGA
*/

reg [1:0] state/* synthesis syn_encoding = "safe, one-hot" */;
reg [7:0] sync_tmr;

localparam 	IDDLE		= 2'b00,
				BLINK		= 2'b01,
				END		= 2'b10;
					
always @ (posedge msec or posedge reset) begin
	if (reset) begin
		LED_FPGA	<= 1'b0;
		sync_tmr	<= 8'b0;
	end

	else begin
		if (synchro) begin
			
			case (state)
				IDDLE: begin
					LED_FPGA	<= 1'b0;
					sync_tmr	<= 8'b0;
					
					if (SYNC) state	<= BLINK;
					
				end
				
				BLINK: begin
					LED_FPGA <= 1'b1;
					
					if(sync_tmr == 20)	state <= END;
					
					else sync_tmr <= sync_tmr + 8'b1;
				
				end
				
				END: begin
					LED_FPGA <= 1'b0;
					sync_tmr	<= 8'b0;
					if (~SYNC) state <= IDDLE;
				end
				
			endcase
			
		end
		
		else  begin
		
			if (sync_tmr	== 31) begin
				LED_FPGA		<= ~LED_FPGA;
				sync_tmr		<= 8'b0;
			end
			
			else sync_tmr	<= sync_tmr + 8'b1;
			
		end
		
	end
end


endmodule