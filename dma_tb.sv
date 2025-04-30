module dma_tb ();

	logic clk, rst, req, grant;
	logic [13:0] addr;
	logic [ 9:0] indata, D_DATA;
	logic [ 1:0] D_STATE;

	dma dma_dut (
		.clk     (clk),
		.rst     (rst),
		
		.req     (req),
		.addr    (addr),
		
		.grant   (grant),
		.indata  (indata),
		
		.D_STATE (D_STATE),
		.D_DATA  (D_DATA)
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
		grant = 1'b0;
		indata = 'z;
		
		wait(req);
		repeat (3) @(posedge clk);
		
		grant = 1'b1;
		@(posedge clk);
		
		indata = 'd7;
		@(posedge clk);
		
		grant = 1'b0;
		indata = 'z;
		@(posedge clk);
	
		$finish;
	end

endmodule