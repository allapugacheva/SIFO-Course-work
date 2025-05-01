`timescale 1 ns / 1 ps

module tb ();

	logic        clk, rst, clk_en, stall;
	logic [13:0] pc, memInAddr, mem1OutAddr, mem2OutAddr, mem3OutAddr, mem4OutAddr, index, addr, dma_addr, cache_ram_addr;
	logic [29:0] instr;
	logic [ 9:0] mem1Out, mem2Out, mem3Out, mem4Out, memIn, op1, op2, gpr1Out, gpr2Out, gpr3Out, aluRes, res, stackOut;
	logic [ 3:0] gpr2Addr, gpr3Addr;
	logic [ 2:0] state;
	logic        instrWrite, gf, sf, g, s, op1RE, op2RE, RiRE, pcEn, mem1RE, mem2RE, mem3RE, mem4RE, 
					 reg1RE, reg2RE, reg3RE, memWE, regWE, pcSrc, resultSrc, push, pop;
	logic        inready, outready1, outready2, outready3, outready4, ram_read, ram_write, req1, grant1, grant2;
	logic [ 1:0] arb_priority, dma_state;
	logic [ 9:0] dma_data;
	logic [13:0] ram_addr;
	logic [ 9:0] ram_indata, ram_outdata;
	logic [ 5:0] cache_data_cnt;
	logic [ 6:0] cache_index, cache_write_index;
	logic [ 9:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, 
					 stack1, stack2, stack3, stack4, stack5, stack6, stack7;

	microprocessor microprocessor_dut (
		.clk          (clk),
		.rst          (rst),
		
		.D_STALL      (stall),
		
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
		.D_INSTR      (instr),
		.D_OP1        (op1),
		.D_OP2        (op2),
		.D_INDEX      (index),
		.D_ADDR       (addr),
		.D_G          (g),
		.D_S          (s),
		.D_OP1RE      (op1RE),
		.D_OP2RE      (op2RE),
		.D_RIRE       (RiRE),
		.D_PCEN       (pcEn),
		.D_REG1RE     (reg1RE),
		.D_REG2RE     (reg2RE),
		.D_REG3RE     (reg3RE),
		.D_REGWE      (regWE),
		.D_PCSRC      (pcSrc),
		.D_RESULTSRC  (resultSrc),
		.D_GPR1OUT    (gpr1Out),
		.D_GPR2OUT    (gpr2Out),
		.D_GPR3OUT    (gpr3Out),
		.D_GPR2ADDR   (gpr2Addr),
		.D_GPR3ADDR   (gpr3Addr),
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
		
		.D_RAMADDR    (ram_addr),
		.D_CACHERAMADDR (cache_ram_addr),
		.D_DMAADDR    (dma_addr),
		.D_RAMINDATA  (ram_indata),
		.D_RAMOUTDATA (ram_outdata),
		.D_RAMREAD    (ram_read),
		.D_RAMWRITE   (ram_write),
		.D_INREADY    (inready),
		.D_OUTREADY1  (outready1),
		.D_OUTREADY2  (outready2),
		.D_OUTREADY3  (outready3),
		.D_OUTREADY4  (outready4),
		
		.D_CACHEDATACNT    (cache_data_cnt),
		.D_CACHEINDEX      (cache_index),
		.D_CACHEWRITEINDEX (cache_write_index),
		
		.D_DMASTATE   (dma_state),
		.D_PRIORITY   (arb_priority),
		.D_REQ1       (req1),
		.D_GRANT1     (grant1),
		.D_GRANT2     (grant2),
		.D_DMADATA    (dma_data),
	
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

		@(negedge clk_en);
		
		$writememb("D:/SifoCourseWork/ram1.mem", microprocessor_dut.memory_module.ram);
		$writememb("D:/SifoCourseWork/cache.mem", microprocessor_dut.cache_module.mem);
		
		$finish;
	end

endmodule