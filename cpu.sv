module cpu (
	input clk,
	input rst,
	
	output [13:0] m_addr,
	output [ 9:0] m_indata,
	output        m_write,
	output        m_read,
	input  [ 9:0] m_outdata,
	
	output [13:0] D_PC,
	output [29:0] D_INSTR,
	output [ 9:0] D_OP1,
	output [ 9:0] D_OP2,
	output [13:0] D_INDEX,
	output [13:0] D_ADDR,
	output        D_G,
	output        D_S,
	output        D_OP1RE,
	output        D_OP2RE,
	output        D_RIHRE,
	output        D_RILRE,
	output        D_PCEN,
	output        D_REGRE,
	output        D_REGWE,
	output        D_PCSRC,
	output        D_RESULTSRC,
	output        D_MEMADDRSRC,
	output [ 9:0] D_GPROUT,
	output [ 3:0] D_GPRADDR,
	output [ 9:0] D_ALURES,
	output [ 9:0] D_RES,
	output [ 1:0] D_INSTRWRITE,
	output        D_PUSH,
	output        D_POP,
	output [ 9:0] D_STACKOUT,
	output [ 2:0] D_STATE,
	output        D_SF,
	output        D_GF,
	output        D_CLKEN,
	
	output [ 9:0] D_REG1,
	output [ 9:0] D_REG2,
	output [ 9:0] D_REG3,
	output [ 9:0] D_REG4,
	output [ 9:0] D_REG5,
	output [ 9:0] D_REG6,
	output [ 9:0] D_REG7,
	output [ 9:0] D_REG8,
	output [ 9:0] D_REG9,
	output [ 9:0] D_REG10,
	
	output [ 9:0] D_STACK1,
	output [ 9:0] D_STACK2,
	output [ 9:0] D_STACK3,
	output [ 9:0] D_STACK4,
	output [ 9:0] D_STACK5,
	output [ 9:0] D_STACK6,
	output [ 9:0] D_STACK7
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
	
	logic clk_en, clk_in;
	assign clk_in = clk & clk_en;
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			clk_en <= 1'b1;
		else if (instr[29:25] == 5'b10011)
			clk_en <= 1'b0;
	
	always_ff @ (posedge clk_in or posedge rst)
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
	
	assign m_addr   = mem_addr;
	assign m_indata = res;
	assign m_write  = memWE;
	assign m_read   = memRE;
	assign mem_out  = m_outdata;
	
	always_ff @ (posedge clk_in or posedge rst)
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
		.clk     (clk_in),
		.rst     (rst),
		
		.addr    (gpr_addr),
		.indata  (res),
		
		.read    (regRE),
		.write   (regWE),
		
		.outdata (gpr_out),
		
		.D_REG1  (D_REG1),
		.D_REG2  (D_REG2),
		.D_REG3  (D_REG3),
		.D_REG4  (D_REG4),
		.D_REG5  (D_REG5),
		.D_REG6  (D_REG6),
		.D_REG7  (D_REG7),
		.D_REG8  (D_REG8),
		.D_REG9  (D_REG9),
		.D_REG10 (D_REG10)
	);
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			op1 <= '0;
		else if (op1RE)
			op1 <= regRE ? gpr_out : mem_out;
			
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			op2 <= '0;
		else if (op2RE)
			op2 <= regRE ? gpr_out : mem_out;
			
	always_ff @ (posedge clk_in or posedge rst)
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
		.clk     (clk_in),
		.rst     (rst),
		
		.push    (push),
		.indata  (res),
		
		.pop     (pop),
		.outdata (stack_out),
	
		.D_STACK1(D_STACK1),
		.D_STACK2(D_STACK2),
		.D_STACK3(D_STACK3),
		.D_STACK4(D_STACK4),
		.D_STACK5(D_STACK5),
		.D_STACK6(D_STACK6),
		.D_STACK7(D_STACK7)
	);
	
	cu cu_module (
		.clk        (clk_in),
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
		.pop        (pop),
		
		.D_STATE    (D_STATE),
		.D_SF       (D_SF),
		.D_GF       (D_GF)
	);
	
	assign D_PC         = pc;
	assign D_INSTR      = instr;
	assign D_OP1        = op1;
	assign D_OP2        = op2;
	assign D_INDEX      = index;
	assign D_ADDR       = addr;
	assign D_G          = g;
	assign D_S          = s;
	assign D_OP1RE      = op1RE;
	assign D_OP2RE      = op2RE;
	assign D_RIHRE      = RiHRE;
	assign D_RILRE      = RiLRE;
	assign D_PCEN       = pcEn;
	assign D_REGRE      = regRE;
	assign D_REGWE      = regWE;
	assign D_PCSRC      = pcSrc;
	assign D_RESULTSRC  = resultSrc;
	assign D_MEMADDRSRC = memAddrSrc;
	assign D_GPROUT     = gpr_out;
	assign D_GPRADDR    = gpr_addr;
	assign D_ALURES     = aluRes;
	assign D_RES        = res;
	assign D_INSTRWRITE = instrWrite;
	assign D_PUSH       = push;
	assign D_POP        = pop;
	assign D_STACKOUT   = stack_out;
	assign D_CLKEN      = clk_en;

endmodule