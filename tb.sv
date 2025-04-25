`timescale 1 ns / 1 ps

module tb ();

	logic        clk, rst, clk_en;
	logic [13:0] pc, memAddr, index, addr;
	logic [29:0] instr;
	logic [ 9:0] memOut, memIn, op1, op2, gprOut, aluRes, res, stackOut, 
					 reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, 
					 stack1, stack2, stack3, stack4, stack5, stack6, stack7;
	logic [ 3:0] gprAddr;
	logic [ 2:0] state;
	logic [ 1:0] instrWrite;
	logic        gf, sf, g, s, op1RE, op2RE, RiHRE, RiLRE, pcEn, memRE, regRE, memWE, regWE, pcSrc, resultSrc, memAddrSrc, push, pop;

	microprocessor microprocessor_dut (
		.clk          (clk),
		.rst          (rst),
		
		.D_MADDR      (memAddr),
		.D_MINDATA    (memIn),
		.D_MWRITE     (memWE),
		.D_MREAD      (memRE),
		.D_MOUTDATA   (memOut),
		
		.D_PC         (pc),
		.D_INSTR      (instr),
		.D_OP1        (op1),
		.D_OP2        (op2),
		.D_INDEX      (index),
		.D_ADDR       (addr),
		.D_G          (g),
		.D_S          (s),
		.D_OP1RE      (op1RE),
		.D_OP2RE      (op2RE),
		.D_RIHRE      (RiHRE),
		.D_RILRE      (RiLRE),
		.D_PCEN       (pcEn),
		.D_REGRE      (regRE),
		.D_REGWE      (regWE),
		.D_PCSRC      (pcSrc),
		.D_RESULTSRC  (resultSrc),
		.D_MEMADDRSRC (memAddrSrc),
		.D_GPROUT     (gprOut),
		.D_GPRADDR    (gprAddr),
		.D_ALURES     (aluRes),
		.D_RES        (res),
		.D_INSTRWRITE (instrWrite),
		.D_PUSH       (push),
		.D_POP        (pop),
		.D_STACKOUT   (stackOut),
		.D_STATE      (state),
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
	
		repeat (134) @(posedge clk);
		
		$writememb("D:/SifoCourseWork/ram1.mem", microprocessor_dut.memory_module.ram);
		
		$finish;
	end

endmodule