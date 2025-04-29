`timescale 1 ns / 1 ps

module tb ();

	logic        clk, rst, clk_en;
	logic [13:0] pc, memInAddr, mem1OutAddr, mem2OutAddr, mem3OutAddr, mem4OutAddr, index_s3, index_s4, index_s5, addr_s4, addr_s5;
	logic [29:0] instr_s2, instr_s3, instr_s4, instr_s5;
	logic [ 9:0] mem1Out, mem2Out, mem3Out, mem4Out, memIn, op1, op2, gpr1Out, gpr2Out, gpr3Out, gpr4Out, aluRes, res, stackOut;
	logic [ 3:0] gpr1Addr, gpr2Addr, gpr4Addr;
	logic        instrWrite, gf, sf, g, s, op1RE, op2RE, RiRE, pcEn, mem1RE, mem2RE, mem3RE, mem4RE, 
					 reg1RE, reg2RE, reg3RE, reg4RE, memWE, regWE, pcSrc, resultSrc, push, pop;
	logic [ 9:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, 
					 stack1, stack2, stack3, stack4, stack5, stack6, stack7;

	microprocessor microprocessor_dut (
		.clk          (clk),
		.rst          (rst),
		
		.D_WRITE      (memWE),
		.D_INADDR     (memInAddr),
		.D_INDATA     (memIn),
		
		.D_READ1      (mem1RE),
		.D_OUTADDR1   (mem1OutAddr),
		.D_OUTDATA1   (mem1Out),
		
		.D_READ2      (mem2RE),
		.D_OUTADDR2   (mem2OutAddr),
		.D_OUTDATA2   (mem2Out),
		
		.D_READ3      (mem3RE),
		.D_OUTADDR3   (mem3OutAddr),
		.D_OUTDATA3   (mem3Out),
		
		.D_READ4      (mem4RE),
		.D_OUTADDR4   (mem4OutAddr),
		.D_OUTDATA4   (mem4Out),
		
		.D_PC         (pc),
		.D_INSTRS2      (instr_s2),
		.D_INSTRS3      (instr_s3),
		.D_INSTRS4      (instr_s4),
		.D_INSTRS5      (instr_s5),
		.D_OP1        (op1),
		.D_OP2        (op2),
		.D_INDEXS3      (index_s3),
		.D_INDEXS4      (index_s4),
		.D_INDEXS5      (index_s5),
		.D_ADDRS4       (addr_s4),
		.D_ADDRS5       (addr_s5),
		.D_G          (g),
		.D_S          (s),
		.D_OP1RE      (op1RE),
		.D_OP2RE      (op2RE),
		.D_RIRE       (RiRE),
		.D_PCEN       (pcEn),
		.D_REG1RE     (reg1RE),
		.D_REG2RE     (reg2RE),
		.D_REG3RE     (reg3RE),
		.D_REG4RE     (reg4RE),
		.D_REGWE      (regWE),
		.D_PCSRC      (pcSrc),
		.D_RESULTSRC  (resultSrc),
		.D_GPR1OUT    (gpr1Out),
		.D_GPR2OUT    (gpr2Out),
		.D_GPR3OUT    (gpr3Out),
		.D_GPR4OUT    (gpr4Out),
		.D_GPR1ADDR   (gpr1Addr),
		.D_GPR2ADDR   (gpr2Addr),
		.D_GPR4ADDR   (gpr4Addr),
		.D_ALURES     (aluRes),
		.D_RES        (res),
		.D_INSTRWRITE (instrWrite),
		.D_PUSH       (push),
		.D_POP        (pop),
		.D_STACKOUT   (stackOut),
		.D_SF         (sf),
		.D_GF         (gf),
		.D_CLKEN      (clk_en),
	
		.D_REG1       (reg1),
		.D_REG2       (reg2),
		.D_REG3       (reg3),
		.D_REG4       (reg4),
		.D_REG5       (reg5),
		.D_REG6       (reg6),
		.D_REG7       (reg7),
		.D_REG8       (reg8),
		.D_REG9       (reg9),
		.D_REG10      (reg10),
		
		.D_STACK1     (stack1),
		.D_STACK2     (stack2),
		.D_STACK3     (stack3),
		.D_STACK4     (stack4),
		.D_STACK5     (stack5),
		.D_STACK6     (stack6),
		.D_STACK7     (stack7)
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
		@(negedge rst);
	
		@(negedge clk_en);
		
		$writememb("D:/SifoCourseWork/ram1.mem", microprocessor_dut.memory_module.ram);
		
		$finish;
	end

endmodule