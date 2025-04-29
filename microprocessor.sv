module microprocessor (
	input         clk,
	input         rst,
		
	output        D_WRITE,
	output [13:0] D_INADDR,
	output [ 9:0] D_INDATA,
	
	output        D_READ1,
	output [13:0] D_OUTADDR1,
	output [ 9:0] D_OUTDATA1,
	
	output        D_READ2,
	output [13:0] D_OUTADDR2,
	output [ 9:0] D_OUTDATA2,
	
	output        D_READ3,
	output [13:0] D_OUTADDR3,
	output [ 9:0] D_OUTDATA3,
	
	output        D_READ4,
	output [13:0] D_OUTADDR4,
	output [ 9:0] D_OUTDATA4,
	
	output [13:0] D_PC,
	output [29:0] D_INSTRS2,
	output [29:0] D_INSTRS3,
	output [29:0] D_INSTRS4,
	output [29:0] D_INSTRS5,
	output [ 9:0] D_OP1,
	output [ 9:0] D_OP2,
	output [13:0] D_INDEXS3,
	output [13:0] D_INDEXS4,
	output [13:0] D_INDEXS5,
	output [13:0] D_ADDRS4,
	output [13:0] D_ADDRS5,
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

	logic [13:0] inaddr, outaddr1, outaddr2, outaddr3, outaddr4;
	logic [ 9:0] indata, outdata1, outdata2, outdata3, outdata4;
	logic        memWE, mem1RE, mem2RE, mem3RE, mem4RE;
	
	assign D_WRITE    = memWE;
	assign D_INADDR   = inaddr;
	assign D_INDATA   = indata;
	
	assign D_READ1    = mem1RE;
	assign D_OUTADDR1 = outaddr1;
	assign D_OUTDATA1 = outdata1;
	
	assign D_READ2    = mem2RE;
	assign D_OUTADDR2 = outaddr2;
	assign D_OUTDATA2 = outdata2;
	
	assign D_READ3    = mem3RE;
	assign D_OUTADDR3 = outaddr3;
	assign D_OUTDATA3 = outdata3;
	
	assign D_READ4    = mem4RE;
	assign D_OUTADDR4 = outaddr4;
	assign D_OUTDATA4 = outdata4;

	cpu cpu_module (
		.clk          (clk),
		.rst          (rst),
		
		.m_write      (memWE),
		.m_inaddr     (inaddr),
		.m_indata     (indata),
		
		.m_read1      (mem1RE),
		.m_outaddr1   (outaddr1),
		.m_outdata1   (outdata1),
		
		.m_read2      (mem2RE),
		.m_outaddr2   (outaddr2),
		.m_outdata2   (outdata2),
		
		.m_read3      (mem3RE),
		.m_outaddr3   (outaddr3),
		.m_outdata3   (outdata3),
		
		.m_read4      (mem4RE),
		.m_outaddr4   (outaddr4),
		.m_outdata4   (outdata4),
		
		.D_PC         (D_PC),
		.D_INSTRS2      (D_INSTRS2),
		.D_INSTRS3      (D_INSTRS3),
		.D_INSTRS4      (D_INSTRS4),
		.D_INSTRS5      (D_INSTRS5),
		.D_OP1        (D_OP1),
		.D_OP2        (D_OP2),
		.D_INDEXS3      (D_INDEXS3),
		.D_INDEXS4      (D_INDEXS4),
		.D_INDEXS5      (D_INDEXS5),
		.D_ADDRS4       (D_ADDRS4),
		.D_ADDRS5       (D_ADDRS5),
		.D_G          (D_G),
		.D_S          (D_S),
		.D_OP1RE      (D_OP1RE),
		.D_OP2RE      (D_OP2RE),
		.D_RIRE       (D_RIRE),
		.D_PCEN       (D_PCEN),
		.D_REG1RE     (D_REG1RE),
		.D_REG2RE     (D_REG2RE),
		.D_REG3RE     (D_REG3RE),
		.D_REG4RE     (D_REG4RE),
		.D_REGWE      (D_REGWE),
		.D_PCSRC      (D_PCSRC),
		.D_RESULTSRC  (D_RESULTSRC),
		.D_GPR1OUT    (D_GPR1OUT),
		.D_GPR2OUT    (D_GPR2OUT),
		.D_GPR3OUT    (D_GPR3OUT),
		.D_GPR4OUT    (D_GPR4OUT),
		.D_GPR1ADDR   (D_GPR1ADDR),
		.D_GPR2ADDR   (D_GPR2ADDR),
		.D_GPR4ADDR   (D_GPR4ADDR),
		.D_ALURES     (D_ALURES),
		.D_RES        (D_RES),
		.D_INSTRWRITE (D_INSTRWRITE),
		.D_PUSH       (D_PUSH),
		.D_POP        (D_POP),
		.D_STACKOUT   (D_STACKOUT),
		.D_SF         (D_SF),
		.D_GF         (D_GF),
		.D_CLKEN      (D_CLKEN),
		
		.D_REG1       (D_REG1),
		.D_REG2       (D_REG2),
		.D_REG3       (D_REG3),
		.D_REG4       (D_REG4),
		.D_REG5       (D_REG5),
		.D_REG6       (D_REG6),
		.D_REG7       (D_REG7),
		.D_REG8       (D_REG8),
		.D_REG9       (D_REG9),
		.D_REG10      (D_REG10),
		
		.D_STACK1     (D_STACK1),
		.D_STACK2     (D_STACK2),
		.D_STACK3     (D_STACK3),
		.D_STACK4     (D_STACK4),
		.D_STACK5     (D_STACK5),
		.D_STACK6     (D_STACK6),
		.D_STACK7     (D_STACK7)
	);
	
	memory memory_module (
		.clk      (clk),
		
		.write    (memWE),
		.inaddr   (inaddr),
		.indata   (indata),
		
		.read1    (mem1RE),
		.outaddr1 (outaddr1),
		.outdata1 (outdata1),
		
		.read2    (mem2RE),
		.outaddr2 (outaddr2),
		.outdata2 (outdata2),
		
		.read3    (mem3RE),
		.outaddr3 (outaddr3),
		.outdata3 (outdata3),
		
		.read4    (mem4RE),
		.outaddr4 (outaddr4),
		.outdata4 (outdata4)
	);

endmodule