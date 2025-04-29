module cpu (
	input         clk,
	input         rst,
	
	input         stall,
	
	output        m_write,
	output [13:0] m_inaddr,
	output [ 9:0] m_indata,
	
	output        m_read1,
	output [13:0] m_outaddr1,
	input  [ 9:0] m_outdata1,
	
	output        m_read2,
	output [13:0] m_outaddr2,
	input  [ 9:0] m_outdata2,

	output        m_read3,
	output [13:0] m_outaddr3,
	input  [ 9:0] m_outdata3,	
	
	output        m_read4,
	output [13:0] m_outaddr4,
	input  [ 9:0] m_outdata4,	
	
	output [13:0] D_PC,
	output        D_CLKIN,
	output [29:0] D_INSTRS2,
	output [29:0] D_INSTRS3,
	output [29:0] D_INSTRS4,
	output [ 9:0] D_OP1,
	output [ 9:0] D_OP2,
	output [13:0] D_INDEXS3,
	output [13:0] D_INDEXS4,
	output [13:0] D_ADDRS3,
	output [13:0] D_ADDRS4,
	output        D_G,
	output        D_S,
	output        D_OP1RE,
	output        D_OP2RE,
	output        D_RIRE,
	output        D_PCEN,
	output        D_REG1RE,
	output        D_REG2RE,
	output        D_REG3RE,
	output        D_REG4RE,
	output        D_REGWE,
	output        D_PCSRC,
	output        D_RESULTSRC,
	output [ 9:0] D_GPR1OUT,
	output [ 9:0] D_GPR2OUT,
	output [ 9:0] D_GPR3OUT,
	output [ 9:0] D_GPR4OUT,
	output [ 3:0] D_GPR1ADDR,
	output [ 3:0] D_GPR2ADDR,
	output [ 3:0] D_GPR4ADDR,
	output [ 9:0] D_ALURES,
	output [ 9:0] D_RES,
	output        D_INSTRWRITE,
	output        D_PUSH,
	output        D_POP,
	output [ 9:0] D_STACKOUT,
	output        D_SF,
	output        D_GF,
	output        D_CLKEN,
	output [4:0]  D_OPCODES3,
	output [4:0]  D_OPCODES4,
	output [3:0]  D_VLD,
	
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
	logic [29:0] instr_s2, instr_s3, instr_s4;
	logic [13:0] mem_addr;
	logic [ 9:0] mem1_out, mem2_out, mem3_out, mem4_out;
	logic [ 9:0] op1, op2;
	logic [13:0] index_s3, index_s4, addr_s3, addr_s4;
	logic        op1RE, op2RE, RiRE, pcEn, mem1RE, mem2RE, mem3RE, mem4RE, reg1RE, reg2RE, reg3RE, reg4RE, memWE, regWE;
	logic        pcSrc, resultSrc, memAddrSrc, instrWrite;
	logic [ 9:0] aluRes, res;
	logic        push, pop;
	logic [ 9:0] stack_out;
	
	logic clk_en, clk_in;
	assign clk_in = clk && clk_en && ~stall;
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			clk_en <= 1'b1;
		else if (instr_s2[29:25] == 5'b10011)
			clk_en <= 1'b0;
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			pc <= 14'b10000000000000;
		else if (pcEn)
			pc <= pcSrc ? instr_s4[13:0] : (pc + 2'b11);	
	
	always_comb begin
		addr_s3 = 'z;
		
		if (   instr_s3[29:25] == 5'b00000
			 || instr_s3[29:25] == 5'b10001 )
			addr_s3 = instr_s3[13:0];
		else if (   instr_s3[29:25] == 5'b00110
					|| instr_s3[29:25] == 5'b00111
					|| instr_s3[29:25] == 5'b01001
					|| instr_s3[29:25] == 5'b01011 )
			addr_s3 = instr_s3[13:0] + index_s3;
	end
	
	always_comb begin
		addr_s4 = 'z;
		
		if (   instr_s4[29:25] == 5'b00001 )
			addr_s4 = instr_s4[13:0];
		else if (   instr_s4[29:25] == 5'b00010
					|| instr_s4[29:25] == 5'b00110
					|| instr_s4[29:25] == 5'b00111
					|| instr_s4[29:25] == 5'b01001
					|| instr_s4[29:25] == 5'b01011 )
			addr_s4 = instr_s4[13:0] + index_s4;
	end
	
	assign res        = resultSrc ? op1 : (pop ? stack_out : aluRes);
	
	assign m_write    = memWE;
	assign m_inaddr   = addr_s4;
	assign m_indata   = res;
	
	assign m_read1    = mem1RE;
	assign m_outaddr1 = pc;
	assign mem1_out   = m_outdata1;
	
	assign m_read2    = mem2RE;
	assign m_outaddr2 = pc + 2'b01;
	assign mem2_out   = m_outdata2;
	
	assign m_read3    = mem3RE;
	assign m_outaddr3 = pc + 2'b10;
	assign mem3_out   = m_outdata3;
	
	assign m_read4    = mem4RE;
	assign m_outaddr4 = addr_s3;
	assign mem4_out   = m_outdata4;
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst) begin
			instr_s2 <= '0;
			instr_s3 <= '0;
			instr_s4 <= '0;
		end
		else begin 
			instr_s2 <= { mem1_out, mem2_out, mem3_out };
			instr_s3 <= instr_s2;
			instr_s4 <= instr_s3;
		end
	
	logic [9:0] gpr_in, gpr1_out, gpr2_out, gpr3_out, gpr4_out;
	
	logic [3:0] gpr1_addr, gpr2_addr, gpr4_addr;
	
	always_comb begin
		gpr1_addr = 'z;
	
		case (instr_s2[19:16])
			4'b1010: gpr1_addr = 4'b0001; // AX -> AH
			4'b1011: gpr1_addr = 4'b0011; // BX -> BH
			4'b1100: gpr1_addr = 4'b0101; // CX -> CH
			4'b1101: gpr1_addr = 4'b0111; // DX -> DH
			4'b1110: gpr1_addr = 4'b1001; // EX -> EH
		endcase
	end
	
	always_comb begin
		gpr2_addr = 'z;
		
		case (instr_s2[19:16])
			4'b1010: gpr2_addr = 4'b0000; // AX -> AL
			4'b1011: gpr2_addr = 4'b0010; // BX -> BL
			4'b1100: gpr2_addr = 4'b0100; // CX -> CL
			4'b1101: gpr2_addr = 4'b0110; // DX -> DL
			4'b1110: gpr2_addr = 4'b1000; // EX -> EL
		endcase
	end
	
	always_comb begin
		gpr4_addr = 'z;
		
		if (   instr_s3[29:25] == 5'b00111
			 || instr_s3[29:25] == 5'b01001
			 || instr_s3[29:25] == 5'b01011 )
			gpr4_addr = instr_s3[24:21];
		else if (   instr_s3[29:25] == 5'b01000
					|| instr_s3[29:25] == 5'b01010
					|| instr_s3[29:25] == 5'b01100 )
			gpr4_addr = instr_s3[19:16];
	end
	
	gpr gpr_module (
		.clk      (clk_in),
		.rst      (rst),
		
		.write    (regWE),
		.inaddr   (instr_s2[24:21]),
		.indata   (res),
		
		.read1    (reg1RE),	
		.outaddr1 (gpr1_addr),
		.outdata1 (gpr1_out),
		
		.read2    (reg2RE),
		.outaddr2 (gpr2_addr),
		.outdata2 (gpr2_out),
		
		.read3    (reg3RE),
		.outaddr3 (instr_s3[24:21]),
		.outdata3 (gpr3_out),
		
		.read4    (reg4RE),
		.outaddr4 (gpr4_addr),
		.outdata4 (gpr4_out),
		
		.D_REG1   (D_REG1),
		.D_REG2   (D_REG2),
		.D_REG3   (D_REG3),
		.D_REG4   (D_REG4),
		.D_REG5   (D_REG5),
		.D_REG6   (D_REG6),
		.D_REG7   (D_REG7),
		.D_REG8   (D_REG8),
		.D_REG9   (D_REG9),
		.D_REG10  (D_REG10)
	);
	
	always_ff @ (posedge clk_in or posedge rst)
		if (rst) 
			op1 <= '0;
		else 
			if (op1RE)
				op1 <= reg3RE ? gpr3_out : mem4_out;
			
	always_ff @ (posedge clk_in or posedge rst)
		if (rst)
			op2 <= '0;
		else 
			if (op2RE)
				op2 <= reg4RE ? gpr4_out : mem4_out;
			
	always_ff @ (posedge clk_in or posedge rst)
		if (rst) begin
			index_s3 <= '0;
			index_s4 <= '0;
		end
		else begin
			if (RiRE)
				index_s3 <= { gpr1_out[3:0], gpr2_out };
			index_s4 <= index_s3;
		end
	
	logic s, g;
	
	alu alu_module (
		.opcode (instr_s4[29:25]),
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
		
		.stall      (stall),
		
		.opcode     (instr_s2[29:25]),
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
		.reg4RE     (reg4RE),
		 
		.pcEn       (pcEn),
		
		.op1RE      (op1RE),
		.op2RE      (op2RE),
		
		.RiRE       (RiRE),
		
		.pcSrc      (pcSrc),
		
		.instrWrite (instrWrite),
		
		.push       (push),
		.pop        (pop),
		
		.D_SF       (D_SF),
		.D_GF       (D_GF),
		
		.D_OPCODES3 (D_OPCODES3),
		.D_OPCODES4 (D_OPCODES4),
		.D_VLD      (D_VLD)
	);
	
	assign D_PC         = pc;
	assign D_CLKIN      = clk_in;
	assign D_INSTRS2    = instr_s2;
	assign D_INSTRS3    = instr_s3;
	assign D_INSTRS4    = instr_s4;
	assign D_OP1        = op1;
	assign D_OP2        = op2;
	assign D_INDEXS3    = index_s3;
	assign D_INDEXS4    = index_s4;
	assign D_ADDRS3     = addr_s3;
	assign D_ADDRS4     = addr_s4;
	assign D_G          = g;
	assign D_S          = s;
	assign D_OP1RE      = op1RE;
	assign D_OP2RE      = op2RE;
	assign D_RIRE       = RiRE;
	assign D_PCEN       = pcEn;
	assign D_REG1RE     = reg1RE;
	assign D_REG2RE     = reg2RE;
	assign D_REG3RE     = reg3RE;
	assign D_REG4RE     = reg4RE;
	assign D_REGWE      = regWE;
	assign D_PCSRC      = pcSrc;
	assign D_RESULTSRC  = resultSrc;
	assign D_GPR1OUT    = gpr1_out;
	assign D_GPR2OUT    = gpr2_out;
	assign D_GPR3OUT    = gpr3_out;
	assign D_GPR4OUT    = gpr4_out;
	assign D_GPR1ADDR   = gpr1_addr;
	assign D_GPR2ADDR   = gpr2_addr;
	assign D_GPR4ADDR   = gpr4_addr;
	assign D_ALURES     = aluRes;
	assign D_RES        = res;
	assign D_INSTRWRITE = instrWrite;
	assign D_PUSH       = push;
	assign D_POP        = pop;
	assign D_STACKOUT   = stack_out;
	assign D_CLKEN      = clk_en;

endmodule