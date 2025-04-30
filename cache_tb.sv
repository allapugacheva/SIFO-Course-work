module cache_tb ();

	logic clk, rst, grant, write, inready, read1, read2, read3, read4, outready1, outready2, outready3, outready4, ram_read, ram_write;
	logic [13:0] inaddr, outaddr1, outaddr2, outaddr3, outaddr4, ram_addr;
	logic [9:0] indata, outdata1, outdata2, outdata3, outdata4, ram_data_out, ram_data_in;
	logic [5:0] D_DATACNT;
	logic [6:0] D_INDEX, D_WRITEINDEX;
	
	cache cache_dut (
		.clk          (clk),
		.rst          (rst),
		
		.grant        (grant),
		
		.write        (write),
		.inaddr       (inaddr),
		.indata       (indata),
		.inready      (inready),
		
		.read1        (read1),
		.outaddr1     (outaddr1),
		.outdata1     (outdata1),
		.outready1    (outready1),
		
		.read2        (read2),
		.outaddr2     (outaddr2),
		.outdata2     (outdata2),
		.outready2    (outready2),
		
		.read3        (read3),
		.outaddr3     (outaddr3),
		.outdata3     (outdata3),
		.outready3    (outready3),
		
		.read4        (read4),
		.outaddr4     (outaddr4),
		.outdata4     (outdata4),
		.outready4    (outready4),
		
		.ram_addr     (ram_addr),
		.ram_read     (ram_read),
		.ram_data_out (ram_data_out),
		.ram_write    (ram_write),
		.ram_data_in  (ram_data_in),
		
		.D_DATACNT    (D_DATACNT),
		.D_INDEX      (D_INDEX),
		.D_WRITEINDEX (D_WRITEINDEX)	
	);
	
	memory memory_dut (
		.clk     (clk),
		
		.addr    (ram_addr),
		.write   (ram_write),
		.indata  (ram_data_in),
		.read    (ram_read),
		.outdata (ram_data_out)
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
		grant = '1;
		inaddr = 'z;
		outaddr1 = 'z;
		outaddr2 = 'z;
		outaddr3 = 'z;
		outaddr4 = 'z;
		
		read1 = 1'b0;
		read2 = 1'b0;
		read3 = 1'b0;
		read4 = 1'b0;
		write = 1'b0;
		
		indata = 'z;
	
		@(negedge rst);
	
		read1 = 1'b1;
		outaddr1 = 'd0;
		
		read2 = 1'b1;
		outaddr2 = 'd1;
		
		read3 = 1'b1;
		outaddr3 = 'd2;
		wait(outready1 && outready2 && outready3);
		@(posedge clk);
		
		read1 = 1'b0;
		read2 = 1'b0;
		read3 = 1'b0;
		@(posedge clk);
		
		read4 = 1'b1;
		outaddr4  = 'd32;

		repeat (10) @(posedge clk);
		
		write = 1'b1;
		inaddr = 'd4;
		indata = 'd228;
		wait(inready && outready4);
		@(posedge clk);
		inaddr = 'z;
		indata = 'z;
		
		read4 = 1'b0;
		write = 1'b0;
		@(posedge clk);
		
		read1 = 1'b1;
		outaddr1 = 'd3;
		
		read2 = 1'b1;
		outaddr2 = 'd4;
		
		read3 = 1'b1;
		outaddr3 = 'd5;
		wait(outready1 && outready2 && outready3);
		@(posedge clk);
		
		read1 = 1'b0;
		read2 = 1'b0;
		read3 = 1'b0;
		@(posedge clk);
		
		read1 = 1'b1;
		outaddr1 = 'd64;
		read4 = 1'b1;
		outaddr4 = 'd96;
		wait(outready1 && outready4);
		@(posedge clk);
		
		read1 = 1'b0;
		read4 = 1'b0;
		@(posedge clk);
		
		$finish;	
	end

endmodule