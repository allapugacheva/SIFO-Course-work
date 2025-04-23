module cpu (
	input clk,
	input rst
);

	logic [13:0] pc;
	logic [29:0] instr;
	logic [13:0] mem_addr;
	logic [ 9:0] mem_out;
	logic [ 9:0] op1, op2;
	logic [13:0] index, addr;
	logic        op1RE, op2RE, RiHRE, RiLRE, pcEn, memRE, regRE, memWE, regWE;
	logic        pcSrc, resultSrc, memAddrSrc;
	logic [ 9:0] aluRes, res;
	logic [ 1:0] instrWrite;
	logic        push, pop;
	logic [ 9:0] stack_out;
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			pc <= 14'b10000000000000;
		else if (pcEn)
			pc <= pcSrc ? instr[13:0] : (pc + 1'b1);	
	
	always_comb begin
		addr = 'z;
		
		if (   instr[29:25] == 5'b00000
			 || instr[29:25] == 5'b00001
			 || instr[29:25] == 5'b01110
			 || instr[29:25] == 5'b01111
			 || instr[29:25] == 5'b10000
			 || instr[29:25] == 5'b10001 )
			addr = instr[13:0];
		else if (   instr[29:25] == 5'b00010
					|| instr[29:25] == 5'b00110
					|| instr[29:25] == 5'b00111
					|| instr[29:25] == 5'b01001
					|| instr[29:25] == 5'b01011 )
			addr = instr[13:0] + index;
	end
	
	assign mem_addr = memAddrSrc ? pc : addr;
	
	assign res      = resultSrc ? op1 : (pop ? stack_out : aluRes);
	
	memory memory_module (
		.clk     (clk),
		
		.addr    (mem_addr),
		.indata  (res),
		
		.write   (memWE),
		.read    (memRE),
		
		.outdata (mem_out)
	);
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			instr <= '0;
		else if (instrWrite == 2'd0)
			instr[29:20] <= mem_out;
		else if (instrWrite == 2'd1)
			instr[19:10] <= mem_out;
		else if (instrWrite == 2'd2)
			instr[ 9: 0] <= mem_out;
	
	logic [9:0] gpr_in, gpr_out;
	
	logic [3:0] gpr_addr;
	
	always_comb begin
		gpr_addr = 'z;
	
		if (op1RE) begin
			gpr_addr = instr[24:21];
		end
		else if (op2RE) begin
			if (   instr[29:25] == 5'b00111   // XOR  M, R
				 || instr[29:25] == 5'b01001   // NANR M, R
				 || instr[29:25] == 5'b01011 ) // ROR  M, R
				gpr_addr = instr[24:21];
			else if (	instr[29:25] == 5'b01000   // XOR  R1, R2
						|| instr[29:25] == 5'b01010   // NANR R1, R2
						|| instr[29:25] == 5'b01100 ) // ROR  R1, R2
				gpr_addr = instr[19:16];
		end
		else if (RiHRE) begin
			case (instr[19:16])
				4'b1010: gpr_addr = 4'b0001; // AX -> AH
				4'b1011: gpr_addr = 4'b0011; // BX -> BH
				4'b1100: gpr_addr = 4'b0101; // CX -> CH
				4'b1101: gpr_addr = 4'b0111; // DX -> DH
				4'b1110: gpr_addr = 4'b1001; // EX -> EH
			endcase
		end
		else if (RiLRE) begin
			case (instr[19:16])
				4'b1010: gpr_addr = 4'b0000; // AX -> AL
				4'b1011: gpr_addr = 4'b0010; // BX -> BL
				4'b1100: gpr_addr = 4'b0100; // CX -> CL
				4'b1101: gpr_addr = 4'b0110; // DX -> DL
				4'b1110: gpr_addr = 4'b1000; // EX -> EL
			endcase
		end
		else if (regWE)
			gpr_addr = instr[24:21];
	
	end
	
	gpr gpr_module (
		.clk     (clk),
		.rst     (rst),
		
		.addr    (gpr_addr),
		.indata  (res),
		
		.read    (regRE),
		.write   (regWE),
		
		.outdata (gpr_out)
	);
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			op1 <= '0;
		else if (op1RE)
			op1 <= regRE ? gpr_out : mem_out;
			
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			op2 <= '0;
		else if (op2RE)
			op2 <= regRE ? gpr_out : mem_out;
			
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			index <= '0;
		else if (regRE)
			if      (RiHRE)
				index[13:10] <= gpr_out[3:0];
			else if (RiLRE)
				index[ 9: 0] <= gpr_out;
	
	logic s, g;
	
	alu alu_module (
		.opcode (instr[29:25]),
		.op1    (op1),
		.op2    (op2),
		
		.res    (aluRes),
		.s      (s),
		.g      (g)
	);
	
	stack stack_module (
		.clk     (clk),
		.rst     (rst),
		
		.push    (push),
		.indata  (res),
		
		.pop     (pop),
		.outdata (stack_out)
	);
	
	cu cu_module (
		.clk        (clk),
		.rst        (rst),
		
		.opcode     (instr[29:25]),
		.s          (s),
		.g          (g),
		
		.resultSrc  (resultSrc),
		
		.memWE      (memWE),
		.memRE      (memRE),
		
		.regWE      (regWE),
		.regRE      (regRE),
		 
		.pcEn       (pcEn),
		
		.memAddrSrc (memAddrSrc),
		
		.op1RE      (op1RE),
		.op2RE      (op2RE),
		
		.RiHRE      (RiHRE),
		.RiLRE      (RiLRE),
		
		.pcSrc      (pcSrc),
		
		.instrWrite (instrWrite),
		
		.push       (push),
		.pop        (pop)
	);

endmodule