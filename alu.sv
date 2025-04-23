module alu (
	input         [4:0] opcode,
	input  signed [9:0] op1,
	input  signed [9:0] op2,
	
	output signed [9:0] res,
	output              s,  // lower 0
	output              g   // op1 > op2
);
	
	logic [3:0] op2_mod;
	assign op2_mod = op2 % 10;

	always_comb begin
		s = $signed(res)  < '0;
		g =         op1   > op2;
	
		case (opcode)
	
			5'b00101, 5'b00110: res =   op1 - 1'b1;
			5'b00111, 5'b01000: res =   op1 ^ op2;
			5'b01001, 5'b01010: res = ~(op1 & op2);
			5'b01011, 5'b01100: res = (op1 >> op2_mod) | (op1 << (10 - op2_mod));
			5'b10011          : res =   op1 + 1'b1;
			default           : res = 'z;
		
		endcase
	
	end
	
endmodule