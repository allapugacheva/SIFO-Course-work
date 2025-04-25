module microprocessor (
	input clk,
	input rst,
	
	output [13:0] D_MADDR,
	output [ 9:0] D_MINDATA,
	output        D_MWRITE,
	output        D_MREAD,
	output [ 9:0] D_MOUTDATA,
	
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

	logic [13:0] mem_addr;
	logic [ 9:0] mem_input, mem_out;
	logic        memWE, memRE;
	
	assign D_MADDR    = mem_addr;
	assign D_MINDATA  = mem_input;
	assign D_MWRITE   = memWE;
	assign D_MREAD    = memRE;
	assign D_MOUTDATA = mem_out;

	cpu cpu_module (
		.clk          (clk),
		.rst          (rst),
		
		.m_addr       (mem_addr),
		.m_indata     (mem_input),
		.m_write      (memWE),
		.m_read       (memRE),
		.m_outdata    (mem_out),
		
		.D_PC         (D_PC),
		.D_INSTR      (D_INSTR),
		.D_OP1        (D_OP1),
		.D_OP2        (D_OP2),
		.D_INDEX      (D_INDEX),
		.D_ADDR       (D_ADDR),
		.D_G          (D_G),
		.D_S          (D_S),
		.D_OP1RE      (D_OP1RE),
		.D_OP2RE      (D_OP2RE),
		.D_RIHRE      (D_RIHRE),
		.D_RILRE      (D_RILRE),
		.D_PCEN       (D_PCEN),
		.D_REGRE      (D_REGRE),
		.D_REGWE      (D_REGWE),
		.D_PCSRC      (D_PCSRC),
		.D_RESULTSRC  (D_RESULTSRC),
		.D_MEMADDRSRC (D_MEMADDRSRC),
		.D_GPROUT     (D_GPROUT),
		.D_GPRADDR    (D_GPRADDR),
		.D_ALURES     (D_ALURES),
		.D_RES        (D_RES),
		.D_INSTRWRITE (D_INSTRWRITE),
		.D_PUSH       (D_PUSH),
		.D_POP        (D_POP),
		.D_STACKOUT   (D_STACKOUT),
		.D_STATE      (D_STATE),
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
		.clk     (clk),
		
		.addr    (mem_addr),
		.indata  (mem_input),
		
		.write   (memWE),
		.read    (memRE),
		
		.outdata (mem_out)
	);

endmodule