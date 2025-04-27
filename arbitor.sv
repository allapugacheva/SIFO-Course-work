module arbitor (
	input        clk,
	input        rst,
	input        request1,
	input        request2,
	input        busbusy,
	output       grant1,
	output       grant2,
	
	output [1:0] D_PRIORITY
);

	logic [1:0] masters_priority;
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst)
			masters_priority <= 2'b10;
		else if (busbusy)
			masters_priority <= ~masters_priority;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant1 <= 1'b0;
		end
		else if (~request1)
			grant1 <= 1'b0;
		else if (request1 & ~busbusy)
			grant1 <= masters_priority[1] || ~request2;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant2 <= 1'b0;
		end
		else if (~request2)
			grant2 <= 1'b0;
		else if (request2 & ~busbusy)
			grant2 <= masters_priority[0] || ~request1;
	end
	
	assign D_PRIORITY = masters_priority;
	
endmodule
	