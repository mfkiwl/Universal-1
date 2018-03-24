/*
13.06.17: V1.0 first look at adc convertion (AD7983)

	wire 'start' signals to start a convertion
	wire 'sample_rdy' signals for valid data in [15:0] ADC_buff
	'CLK' ~5MHz


	
wire 			sample_rdy;
wire [15:0] ADC_buff;
	
ADC  AD7983(
	 .clock			(clk_5Mhz),
	 .reset			(reset),
	 .start			(ADC_start),
	 
	 .CNV				(CNV),
	 .IRQ				(IRQ),
	 .CLK				(CLK),
	 .SDO		(SDO),
	 
	 .sample_rdy	(sample_rdy),
	 .ADC_buff	(ADC_buff)
);



*/


module ADC (
	clock,
	reset,
	start,
	
	CNV,
	SDI,
	CLK,
	SDO,
	
	sample_rdy,
	ADC_sample
);


input wire 	clock, 
				reset,
				start, 
				SDO;

output wire CLK;
output reg 	CNV,
				SDI,
				sample_rdy;
				
output reg [15:0] ADC_sample;


wire IRQ;	assign IRQ = SDO;

reg [15:0] 	ADC_buff;
reg [4:0] 	bit_cnt;
reg 			clk_ena;

assign 		CLK = clk_ena  ? clock : 1'b1;


reg [2:0] 	state /* synthesis syn_encoding = "safe, one-hot" */;

localparam  IDDLE 	= 3'b000,
				START		= 3'b001,
				WT_RDY	= 3'b010,
				SAMPLE	= 3'b011,
				DELAY		= 3'b100,
				DELAY2	= 3'b101;

always@(posedge reset or posedge clock) begin
	if (reset) begin
		
		CNV			<= 1'b0;
		SDI			<= 1'b0;
		clk_ena 		<= 1'b0;
		sample_rdy	<= 1'b0;
		bit_cnt		<= 5'd15;
		ADC_buff		<= 16'b0;
		ADC_sample	<= 16'b0;
		state			<= IDDLE;
		
	end
	
	else begin
		case (state) 
			IDDLE: begin
				
				SDI			<= 1'b1;
				sample_rdy	<= 1'b0;
				
				if (start) 	state <= START;
				
				else 			state	<= IDDLE;
				
			end
			
			START: begin
				
				CNV		<= 1'b1;
				state		<= WT_RDY;
				clk_ena 	<= 1'b1;
				
			end
			
			DELAY: begin
				
				state		<= DELAY2;
	//=-----------------------------//
				sample_rdy	<= 1'b1;
				ADC_sample	<= ADC_buff;
				
			end
			
			DELAY2: begin
				
				state		<= IDDLE;
				clk_ena 	<= 1'b0;
				
			end
			
			WT_RDY: begin
				
				CNV	<= 1'b0;
				
				if (smpl_start) begin
					
					state 	<= SAMPLE;
					
					bit_cnt		<= bit_cnt - 5'b1;
					ADC_buff[bit_cnt]	<= SDO;
					
				end
				
				else state	<= WT_RDY;
				
			end
			
			SAMPLE: begin
			 
				ADC_buff[bit_cnt]	<= SDO;
				
					if (bit_cnt == 0) begin
					//sample_rdy	<= 1'b1;
					bit_cnt		<= 5'd15;
					//state 		<= IDDLE;
					//clk_ena 		<= 1'b0;	
					state 		<= DELAY;	
					
				end
				
				else begin
					
					bit_cnt		<= bit_cnt - 5'b1;
					state			<= SAMPLE;
					
				end
				
			end
			
		endcase
	end

end

reg smpl_start;

always @ (negedge clock) begin
	
	if ((~IRQ)&&(~sample_rdy))  smpl_start <= 1'b1;
	
	else  smpl_start <= 1'b0;
	
end


endmodule
 