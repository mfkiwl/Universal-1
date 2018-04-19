

always @ (posedge clock)begin
	if (reset) begin
		c_st 			<= INIT_ST;
		c_data		<= 0;
		c_addr		<= 0;
		wren 			<= 0;
	end
	else begin
		c_st 			<= n_st;
		wren 			<= wren_ena;
		c_addr		<= n_addr;
		c_data		<= n_data;
	end
end