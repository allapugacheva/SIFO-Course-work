module stack (
	input  clk,
	input  rst,
	
	input  push,
	input  [9:0] indata,
	
	input  pop,
	output [9:0] outdata
);

	logic [9:0] data [0:6];
	
	logic [2:0] ptr;
	
	always_ff @(posedge clk or posedge rst)
		if (rst) begin
			ptr <= 'd7;
		
			for (int i = 0; i < 7; i++)
				data[i] <= '0;
		end
		else if (push & ptr > 'd0) begin
			data[ptr - 1'b1] <= indata;
			ptr              <= ptr - 1'b1;
		end
		else if (pop & ptr < 'd6) begin
			ptr              <= ptr + 1'b1;
		end
		
	assign outdata = pop & ptr < 'd7 ? data[ptr] : 'z;

endmodule