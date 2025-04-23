module Arbitor (
	input        clk,
	input        rst,
	input        request1,
	input        request2,
	input        request3,
	input        request4,
	input        busbusy,
	output       grant1,
	output       grant2,
	output       grant3,
	output       grant4,
	
	output [7:0] _priority
);

	logic [7:0] masters_priority;
	
	assign _priority = masters_priority;
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst)
			masters_priority <= 8'b11100100;
		else if (busbusy) begin
			case ({grant1, grant2, grant3, grant4})
				4'b1000: masters_priority <= 8'b00111001;
				4'b0100: masters_priority <= 8'b01001110;
				4'b0010: masters_priority <= 8'b10010011;
				4'b0001: masters_priority <= 8'b11100100;
			endcase
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant1 <= 1'b0;
		end
		else if (~request1)
			grant1 <= 1'b0;
		else if (request1 & ~busbusy) begin
			case ({masters_priority[7:6] > masters_priority[5:4], masters_priority[7:6] > masters_priority[3:2], masters_priority[7:6] > masters_priority[1:0]})
				3'b111: grant1 <= 1'b1;
				3'b110: grant1 <= ~request4;
				3'b101: grant1 <= ~request3;
				3'b011: grant1 <= ~request2;
				3'b100: grant1 <= ~request4 & ~request3;
				3'b010: grant1 <= ~request4 & ~request2;
				3'b001: grant1 <= ~request3 & ~request2;
				3'b000: grant1 <= ~request4 & ~request3 & ~request2;
			endcase
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant2 <= 1'b0;
		end
		else if (~request2)
			grant2 <= 1'b0;
		else if (request2 & ~busbusy) begin
			case ({masters_priority[5:4] > masters_priority[7:6], masters_priority[5:4] > masters_priority[3:2], masters_priority[5:4] > masters_priority[1:0]})
				3'b111: grant2 <= 1'b1;
				3'b110: grant2 <= ~request4;
				3'b101: grant2 <= ~request3;
				3'b011: grant2 <= ~request1;
				3'b100: grant2 <= ~request4 & ~request3;
				3'b010: grant2 <= ~request4 & ~request1;
				3'b001: grant2 <= ~request3 & ~request1;
				3'b000: grant2 <= ~request4 & ~request3 & ~request1;
			endcase
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant3 <= 1'b0;
		end
		else if (~request3)
			grant3 <= 1'b0;
		else if (request3 & ~busbusy) begin
			case ({masters_priority[3:2] > masters_priority[7:6], masters_priority[3:2] > masters_priority[5:4], masters_priority[3:2] > masters_priority[1:0]})
				3'b111: grant3 <= 1'b1;
				3'b110: grant3 <= ~request4;
				3'b101: grant3 <= ~request2;
				3'b011: grant3 <= ~request1;
				3'b100: grant3 <= ~request4 & ~request2;
				3'b010: grant3 <= ~request4 & ~request1;
				3'b001: grant3 <= ~request2 & ~request1;
				3'b000: grant3 <= ~request4 & ~request2 & ~request1;
			endcase
		end
	end 
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			grant4 <= 1'b0;
		end
		else if (~request4)
			grant4 <= 1'b0;
		else if (request4 & ~busbusy) begin
			case ({masters_priority[1:0] > masters_priority[7:6], masters_priority[1:0] > masters_priority[5:4], masters_priority[1:0] > masters_priority[3:2]})
				3'b111: grant4 <= 1'b1;
				3'b110: grant4 <= ~request3;
				3'b101: grant4 <= ~request2;
				3'b011: grant4 <= ~request1;
				3'b100: grant4 <= ~request3 & ~request2;
				3'b010: grant4 <= ~request3 & ~request1;
				3'b001: grant4 <= ~request2 & ~request1;
				3'b000: grant4 <= ~request3 & ~request2 & ~request1;
			endcase
		end
	end
	
endmodule
	