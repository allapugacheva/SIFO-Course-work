module arbitor (
	input        clk,
	input        rst,
	
	input        request1,
	input        request2,
	
	output logic grant1,
	output logic grant2,
	
	output [1:0] D_PRIORITY
);

	logic [1:0] masters_priority;
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst)
			masters_priority <= 2'b01;
		else if (grant1 && ~request1)
			masters_priority <= 2'b01;
		else if (grant2 && ~request2)
			masters_priority <= 2'b10;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant1 <= 1'b0;
		end
		else if (~request1)
			grant1 <= 1'b0;
		else if (request1 & ~grant2)
			grant1 <= masters_priority[1] || ~request2;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant2 <= 1'b0;
		end
		else if (~request2)
			grant2 <= 1'b0;
		else if (request2 & ~grant1)
			grant2 <= masters_priority[0] || ~request1;
	end
	
	assign D_PRIORITY = masters_priority;
	
endmodule
	