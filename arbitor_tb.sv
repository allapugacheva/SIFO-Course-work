module arbitor_tb ();

	logic clk, rst, request1, request2, grant1, grant2;
	logic [1:0] D_PRIORITY;

	arbitor arbitor_dut (
		.clk        (clk),
		.rst        (rst),
		
		.request1   (request1),
		.request2   (request2),
		
		.grant1     (grant1),
		.grant2     (grant2),
		
		.D_PRIORITY (D_PRIORITY)
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
		request1 = 1'b0;
		request2 = 1'b0;
		
		@(negedge rst);
		request1 = 1'b1;
		
		wait (grant1);
		@(posedge clk);
		request2 = 1'b1;
		
		@(posedge clk);
		request1 = 1'b0;
		
		wait (grant2);
		@(posedge clk);
		request2 = 1'b0;
		
		@(posedge clk);
		@(posedge clk);
		
		request1 = 1'b1;
		request2 = 1'b1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		request1 = 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		request2 = 1'b0;
		@(posedge clk);
		@(posedge clk);
		
		$finish;
	end

endmodule