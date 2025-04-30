module memory_tb ();

	logic clk, write, read;
	logic [13:0] addr;
	logic [ 9:0] indata, outdata;
	
	memory memory_dut (
		.clk     (clk),
		.addr    (addr),
		
		.write   (write),
		.indata  (indata),
		
		.read    (read),
		.outdata (outdata)
	);
	
	initial begin
		clk = 1'b0;
		
		forever
			#5 clk = ~clk;
	end
	
	initial begin
		write  = 1'b0;
		read   = 1'b0;
		addr   = 'z;
		indata = 'z;
	
		@(posedge clk);
		read = 1'b1;
		addr = 'd1;
		
		@(posedge clk);
		addr = 'd8195;
		
		@(posedge clk);
		read = 1'b0;
		addr = 'z;
		
		@(posedge clk);
		write = 1'b1;
		addr  = 'd1;
		indata = 'd5;
		
		@(posedge clk);
		write = 1'b0;
		addr = 'z;
		indata = 'z;
		
		@(posedge clk);
		read = 1'b1;
		addr = 'd1;
		
		@(posedge clk);
		read = 1'b0;
		addr = 'z;
		
		@(posedge clk);
		$finish;
		
	end

endmodule