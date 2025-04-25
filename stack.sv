module stack (
	input  clk,
	input  rst,
	
	input  push,
	input  [9:0] indata,
	
	input  pop,
	output [9:0] outdata,
	
	output [9:0] D_STACK1,
	output [9:0] D_STACK2,
	output [9:0] D_STACK3,
	output [9:0] D_STACK4,
	output [9:0] D_STACK5,
	output [9:0] D_STACK6,
	output [9:0] D_STACK7
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
	
	assign D_STACK1 = data[0];
	assign D_STACK2 = data[1];
	assign D_STACK3 = data[2];
	assign D_STACK4 = data[3];
	assign D_STACK5 = data[4];
	assign D_STACK6 = data[5];
	assign D_STACK7 = data[6];

endmodule