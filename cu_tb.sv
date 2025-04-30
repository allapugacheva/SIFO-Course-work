module cu_tb ();

	logic clk, rst, stall, s, g;
	logic [4:0] opcode;
	logic resultSrc, memWE, mem1RE, mem2RE, mem3RE, mem4RE, regWE, reg1RE, reg2RE, reg3RE, pcEn, op1RE, op2RE, RiRE, pcSrc, instrWrite, push, pop;
	logic [2:0] D_STATE;
	logic D_SF, D_GF;

	cu cu_dut (
		.clk        (clk),
		.rst        (rst),
		.stall      (stall),
		.opcode     (opcode),
		.s          (s),
		.g          (g),
		
		.resultSrc  (resultSrc),
		.memWE      (memWE),
		.mem1RE     (mem1RE),
		.mem2RE     (mem2RE),
		.mem3RE     (mem3RE),
		.mem4RE     (mem4RE),
		.regWE      (regWE),
		.reg1RE     (reg1RE),
		.reg2RE     (reg2RE),
		.reg3RE     (reg3RE),
		.pcEn       (pcEn),
		.op1RE      (op1RE),
		.op2RE      (op2RE),
		.RiRE       (RiRE),
		.pcSrc      (pcSrc),
		.instrWrite (instrWrite),
		.push       (push),
		.pop        (pop),
		.D_STATE    (D_STATE),
		.D_SF       (D_SF),
		.D_GF       (D_GF)
	);
	
	initial begin
		clk = 1'b0;
		
		forever
			#5 clk = ~clk;
	end
	
	initial begin
		rst = 1'b1;
		
		#10 rst = 1'b0;
	end
	
	initial begin
		stall  = '0;
		opcode = 5'b00011;
		s = '0;
		g = '0;
		
		repeat (5) @(posedge clk);
		opcode = 5'b00111;
		repeat (4) @(posedge clk);
		
		$finish;
	end
	
endmodule