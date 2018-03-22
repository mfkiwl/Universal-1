/*
ARINC_429
ARINC_429_1(
	 .clock			(clk_400kHz),
	 .inp_clk		(inp_clk),
	 .reset			(reset),
	 .line_A			(line_A),
	 .line_B			(line_B),
	 .rdaddress		(rd_arinc1),
	 .q				(arinc_1_outp)
);
*/

module ARINC_429 (
clock,
inp_clk,
reset,
line_A,
line_B,

rdaddress,
q
);


	input wire	clock,
					inp_clk, 
					reset, 
					line_A, line_B;
					
	input wire	[4:0]  rdaddress;
	
	output wire	[15:0]  q;

	
wire line_A_sync;
Sync_input Sync_input_line_A(
	.clock			(clock),
	.signal			(line_A),
	.signal_sync	(line_A_sync)
);
wire line_B_sync;
Sync_input Sync_input_line_B(
	.clock			(clock),
	.signal			(line_B),
	.signal_sync	(line_B_sync)
);

	
wire digi_clk;		assign digi_clk = line_A_sync || line_B_sync;
//--------------------------------------------------------------------------------------------------------//
reg [31:0] 	arinc_buff;
reg [4:0]	arinc_cnt;

always @ (posedge digi_clk or posedge reset) begin 
	if (reset) begin
		arinc_cnt 	<= 5'b0;
		arinc_buff	<= 32'b0;
		wraddress	<= 4'b0;
		wren 			<= 1'b0;
	end
	
	else begin
	 
		wren 			<= 1'b1;
		arinc_cnt 	<= arinc_cnt + 5'b1;
		arinc_buff [arinc_cnt] <= line_A_sync;
		
		if (arinc_cnt == 0) begin
			data			<= arinc_buff;
			wraddress	<= wraddress + 4'b1;
		end	
		
	end
end

//--------------------------------------------------------------------------------------------------------//
	reg	  wren;
	reg	[31:0]  data;
	reg	[3:0]  wraddress;

rz_ram 
rz_ram_unit(
	 .data			(data), 		 
	 .rdaddress		(rdaddress),	//[4:0]
	 .rdclock		(inp_clk),		//[31:0]
	 .wraddress		(wraddress),	//[3:0]	
	 .wrclock		(digi_clk), 	// clock
	 .wren			(wren),
	 .q				(q)				//[15:0]
);

	
endmodule