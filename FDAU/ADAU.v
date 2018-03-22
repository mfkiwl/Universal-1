/*
13.06.17: 

wire 			sample_rdy;
wire [15:0]	ADC_sample;

ADAU 
ADAU_FRAME(
    .clock			(clock),
	 .clk_5Mhz		(clk_5Mhz),
	 .reset			(reset),
	 .msec			(msec),
	 .sec				(sec),
	 
	 .SDO				(SDO),
	 .CNV				(CNV),
	 .SDI				(SDI),
	 .CLK				(CLK),
	 
	 .ADDR			(ADDR),
	 .ENA				(ENA),
	 
	 .TX				(TX_data),
	 
	 .sample_rdy		(sample_rdy),
	 .ADC_sample		(ADC_sample)
);


*/


module ADAU // analog data aquisition unit
(
	clock,
	clk_5Mhz,
	reset,
	msec,
	sec,	
	
	SDO,
	CNV,
	SDI,
	CLK,
	
	ADDR,
	ENA,
	
	TX,	
	
	sample_rdy,
	ADC_sample
);

input  wire 	clock,
					clk_5Mhz,
					reset,
					msec, 
					sec,
					
					SDO;					
output wire 	CNV,
					CLK,
					SDI, 
					
					TX;
					
output reg 	[3:0] ADDR,
						ENA;

//input  wire [8:0] 	rd_adau;
//output wire [15:0] 	q_adau;

output wire 			sample_rdy;
output wire [15:0]	ADC_sample;


wire	[7:0]  new_frame;
wire	[7:0]  new_frame_addr;
wire	  wren;	assign wren = 1'b1;
wire	[7:0]  channel;

frame 
RAM_with_FRAME(
	 .clock			(clk_5Mhz),
	 .data			(new_frame),
	 .rdaddress		(rd_channel),
	 .wraddress		(new_frame_addr),
	 .wren			(wren),
	 .q				(channel)
);



reg [3:0] 	state /* synthesis syn_encoding = "safe, one-hot" */;
localparam  IDDLE 			= 4'd0,

				SYNC				= 4'd1,
				SYNC_DELAY		= 4'd2,
				SYNC_TRANS		= 4'd3,
				
				START				= 4'd4,
				DELAY				= 4'd5,
				WT_RDY			= 4'd6,
				WAIT_TRANSFER	= 4'd7,
				REARANGE			= 4'd8;


				
parameter delay_clocks = 1220;	
				

reg s_word, ADC_start; 
reg [7:0] 	rd_channel;
reg [15:0]	sync_word;
reg [31:0] 	cnt;


always@(posedge reset or posedge clk_5Mhz) begin
	if (reset) begin
		s_word		<= 1'b0;
		sync_word	<= 16'hFF7F;
		state			<= IDDLE;
		//---------------//
			ENA	<= channel[3:0]; // 4'b1;//
			ADDR	<= channel[7:4]; //4'b0;//
		//---------------// 
		rd_channel	<= 1;		
	end
	
	else begin
		case (state) 
			
			IDDLE: begin
			 
				ADC_start	<= 1'b0;
				cnt			<= 32'b0;
					
				if (sec) state	<= SYNC;
				 
				else 		state	<= IDDLE;
				
			end
			
			SYNC: begin
				
				cnt		<= 32'd1050;		
				state		<= WAIT_TRANSFER;
				//-----------------------// 
					ENA	<= channel[3:0]; 
					ADDR	<= channel[7:4]; 
				//-----------------------//
				s_word		<= 1'b1;		
				sync_word	<= 16'hFF7F;	
				
			end
			
			WAIT_TRANSFER: begin
			 
				cnt 		<= cnt + 32'b1;	
				s_word	<= 1'b0;	
				
				if (~busy) 	state	<= DELAY;
				
				else			state	<= WAIT_TRANSFER;
				
			end
			
			DELAY: begin
				
				if (sec)begin
					
					state			<= IDDLE;
					rd_channel	<= 1;//{`FRAME_size{1'd1}};
					
				end
				
				if (cnt == delay_clocks) begin
				 
					ADC_start	<= 1'b1;
					state			<= WT_RDY;
					cnt			<= 32'b0;	//<========
					
					if(rd_channel == 64) rd_channel	<= 1;
					
					else 						rd_channel	<= rd_channel + 1;
					
				end
				
				else cnt <= cnt + 32'b1;
				
			end
			
			WT_RDY: begin 	
					
				cnt 	<= cnt + 32'b1;	//<========
					
				if (sample_rdy) begin
				 
					ADC_start	<= 1'b0;
				//-----------------------//
					ENA		<= 4'h1;		 // SETs MUX to GND
					ADDR 		<= 4'hF;		 // to low V on ADC
				//-----------------------//	
					state	<= REARANGE;
					
				end
				
				else state	<= WT_RDY;
				
			end
			
			REARANGE: begin
			 
				cnt <= cnt + 32'b1;
				
				if (cnt == 72) begin	
					
					state	<= WAIT_TRANSFER;
					
					//-----------------------// 
						ENA	<= channel[3:0]; 
						ADDR	<= channel[7:4]; 
					//-----------------------//
					
				end				
			end
			
		endcase
	end
end
	

ADC  
AD7983
(
	 .clock			(clk_5Mhz),
	 .reset			(reset),
	 .start			(ADC_start),//(msec), //
	 
	 .CNV				(CNV),
	 .SDI				(SDI),
	 .CLK				(CLK),
	 .SDO		(SDO),
	 
	 .sample_rdy	(sample_rdy),
	 .ADC_sample	(ADC_sample)
);


wire busy;

`ifdef RAW_ADC

	parameter FAST_clk = 48, SLOW_clk = 217;

	wire [15:0]	ADC_sample;		assign ADC_sample = s_word ? sync_word	: ADC_sample;
	wire 			SEND_start;		assign SEND_start = s_word ? 1'b1		: sample_rdy;

	UARTx  
			 #(.trans_mode(1),	
				.delay_val(FAST_clk))
	DATA_STREAM (
		 .clock		(clock),
		 .reset		(reset),	
		 .busy		(busy),	
		 .DATA		(ADC_sample),
		 .ENA			(SEND_start),	
		 .tx			(TX)
	);
	
`else 

	assign busy = 1'b0;
	assign TX	= 1'b1;
	
`endif

	
endmodule
 