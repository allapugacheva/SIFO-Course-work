module alu_tb ();

	logic [4:0] opcode;
	logic [9:0] op1, op2, res;
	logic s, g;

	alu alu_dut (
		.opcode (opcode),
		.op1    (op1),
		.op2    (op2),
		
		.res    (res),
		.s      (s),
		.g      (g)
	);
	
	initial begin
		
		op1 = 'd2;
		op2 = 'd4;
		
		opcode = 5'b00101;
		#10;
		opcode = 5'b00111;
		#10;
		opcode = 5'b01001;
		#10;
		opcode = 5'b01011;
		#10;
		opcode = 5'b10010;
		#10;
		
		$finish;
		
	end

endmodule