module gpr_tb ();

	logic clk, rst, write, read1, read2, read3;
	logic [3:0] inaddr, outaddr1, outaddr2, outaddr3;
	logic [9:0] indata, outdata1, outdata2, outdata3, D_REG1, D_REG2, D_REG3, D_REG4, D_REG5, D_REG6, D_REG7, D_REG8, D_REG9, D_REG10;

	gpr gpr_dut (
		.clk      (clk),
		.rst      (rst),
		
		.write    (write),
		.inaddr   (inaddr),
		.indata   (indata),
		
		.read1    (read1),
		.outaddr1 (outaddr1),
		.outdata1 (outdata1),
		
		.read2    (read2),
		.outaddr2 (outaddr2),
		.outdata2 (outdata2),
		
		.read3    (read3),
		.outaddr3 (outaddr3),
		.outdata3 (outdata3),
		
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
		write = 1'b0;
		read1 = 1'b0;
		read2 = 1'b0;
		read3 = 1'b0;
		inaddr = 'z;
		indata = 'z;
		outaddr1 = 'z;
		outaddr2 = 'z;
		outaddr3 = 'z;
		
		@(negedge rst);
		
		write = '1;
		inaddr = 'd0;
		indata = 'd1;
		@(posedge clk);
		
		inaddr = 'd3;
		indata = 'd5;
		@(posedge clk);
		
		inaddr = 'd6;
		indata = 'd7;
		read1  = '1;
		outaddr1 = 'd0;
		@(posedge clk);
		
		write = '0;
		inaddr = 'z;
		indata = 'z;
		read2 = '1;
		outaddr2 = 'd3;
		@(posedge clk);
		
		read3 = '1;
		outaddr3 = 'd6;
		@(posedge clk);
	
		$finish;
	end

endmodule