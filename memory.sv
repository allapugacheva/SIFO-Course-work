module memory (
	input clk,
	
	input  [13:0] addr,
	
	input 		  write,
	input  [ 9:0] indata,
	
	input         read,
	output logic [ 9:0] outdata
);

	logic [9:0] ram [0:8191];
	logic [9:0] rom [0:8191];
	
	logic [9:0] ram_out;
	
	always_ff @(posedge clk) begin
		if (write & ~addr[13])
			ram[addr[12:0]] <= indata;
		if (read)
			outdata <= addr[13] ? rom[addr[12:0]] : ram[addr[12:0]];
	end
	
	initial begin
		$readmemb("D:/SifoCourseWork/rom.mem", rom);
		$readmemb("D:/SifoCourseWork/ram.mem", ram);
	end

endmodule