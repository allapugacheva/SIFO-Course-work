module memory (
	input clk,
	
	input 		  write,
	input  [13:0] inaddr,
	input  [ 9:0] indata,
	
	input         read1,
	input  [13:0] outaddr1,
	output [ 9:0] outdata1,
	
	input         read2,
	input  [13:0] outaddr2,
	output [ 9:0] outdata2,
	
	input         read3,
	input  [13:0] outaddr3,
	output [ 9:0] outdata3,
	
	input         read4,
	input  [13:0] outaddr4,
	output [ 9:0] outdata4
);

	logic [9:0] ram [0:8191];
	logic [9:0] rom [0:8191];
	
	logic [9:0] ram_out1, ram_out2, ram_out3, ram_out4;
	
	always_ff @(posedge clk) begin
		if (write & ~inaddr[13])
			ram[inaddr[12:0]] <= indata;
		if (read1 & ~outaddr1[13])
			ram_out1          <= ram[outaddr1[12:0]];
		if (read2 & ~outaddr2[13])
			ram_out2          <= ram[outaddr2[12:0]];
		if (read3 & ~outaddr3[13])
			ram_out3          <= ram[outaddr3[12:0]];
		if (read4 & ~outaddr4[13])
			ram_out4          <= ram[outaddr4[12:0]];
	end
	
	assign outdata1 = outaddr1[13] ? rom[outaddr1[12:0]] : ram_out1;
	assign outdata2 = outaddr2[13] ? rom[outaddr2[12:0]] : ram_out2;
	assign outdata3 = outaddr3[13] ? rom[outaddr3[12:0]] : ram_out3;
	assign outdata4 = outaddr4[13] ? rom[outaddr4[12:0]] : ram_out4;
	
	initial begin
		$readmemb("D:/SifoCourseWork/rom.mem", rom);
		$readmemb("D:/SifoCourseWork/ram.mem", ram);
	end

endmodule