module alu (
	input         [4:0] opcode,
	input  signed [9:0] op1,
	input  signed [9:0] op2,
	
	output signed [9:0] res,
	output             s,  // lower 0
	output             g,  // op1 > op2
);

	logic [3:0] op2_mod;
	
	assign op2_mod = op2 % 10;

	always_comb begin
		s = $signed(res)  < '0;
		g =         op1   > op2;
	
		case (opcode)
	
			5b'00101, 5b'00110: res =   op1 - 1'b1;
			5b'00111, 5b'01000: res =   op1 ^ op2;
			5b'01001, 5b'01010: res = ~(op1 & op2);
			5b'01011, 5b'01100: res = { op1[op2_mod - 1:0], op1[9 - op2_mod:op2_mod] };
			5b'10011          : res =   op1 + 1'b1;
			default           : res = 'z;
		
		endcase
	
	end
	
endmodule