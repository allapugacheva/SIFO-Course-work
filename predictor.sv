module predictor (
	input              clk,
	input              rst,
	
	input              result,
	input              result_strob,
	
	input              predict_req,
	output             predict,
	
	output [4:0]       D_PATTERN,
	output [1:0]       D_STATE,
	output [1:0]       D_NEWSTATE,
	output [31:0][1:0] D_DATA
);

	logic [4:0] pattern;
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			pattern <= '0;
		else if (result_strob)
			pattern <= { pattern[3:0], result };
			
	logic [1:0] new_state, state;
	logic [31:0][1:0] data;
	assign state = data[pattern];
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			for (int i = 0; i < 32; i++)
				data[i] <= '0;
		else if (result_strob)
			state <= new_state;
			
	always_comb begin
		new_state = state;
		
		if (result_strob)
			case (state)
				2'd0: if ( result) new_state = 2'd1;
				2'd1: if ( result) new_state = 2'd3;
						else         new_state = 2'd0;
				2'd2: if ( result) new_state = 2'd3;
						else         new_state = 2'd0;
				2'd3: if (~result) new_state = 2'd2;
			endcase
	end
	
	assign predict = predict_req ? state[1] : 'z;
	
	assign D_PATTERN  = pattern;
	assign D_STATE    = state;
	assign D_NEWSTATE = new_state;
	assign D_DATA     = data;
	
endmodule