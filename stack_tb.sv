module stack_tb ();

	logic clk, rst, push, pop;
	logic [9:0] indata, outdata, stack1, stack2, stack3, stack4, stack5, stack6, stack7;

	stack stack_dut (
		.clk      (clk),
		.rst      (rst),
		.push     (push),
		.indata   (indata),
		.pop      (pop),
		.outdata  (outdata),
		
		.D_STACK1 (stack1),
		.D_STACK2 (stack2),
		.D_STACK3 (stack3),
		.D_STACK4 (stack4),
		.D_STACK5 (stack5),
		.D_STACK6 (stack6),
		.D_STACK7 (stack7)
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
		push = 1'b0;
		pop = 1'b0;
		indata = 'z;
		@(negedge rst);
		
		push = 1'b1;
		indata = 'd2;
		@(posedge clk);
		
		indata = 'd6;
		@(posedge clk);
		
		push = 1'b0;
		indata = 'z;
		@(posedge clk);
		
		pop = 1'b1;
		@(posedge clk);
		
		@(posedge clk);
		pop = 1'b0;
		
		@(posedge clk);
		
		$finish;
	end

endmodule