/*
(* noprune *) wire sig;

pos_edge_det 
pos_edge_det_UNIT
( 
	 .sig		(sample_rdy),
	 .clk		(clock),
	 .pe		(sample)
);
*/

module pos_edge_det ( 
	input sig,
	input clk,
	output pe
);
 
  reg   sig_dly;
 
  always @ (posedge clk) begin
    sig_dly <= sig;
  end
 
  assign pe = sig & ~sig_dly;
  
endmodule 

