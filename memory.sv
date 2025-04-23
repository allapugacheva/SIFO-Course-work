module memory (
	input clk,
	
	input [13:0] addr,
	input [9:0]  indata,
	
	input 		 write,
	input        read,
	
	output [9:0] outdata
);

	logic [9:0] ram [0:8192]; // 2^13
	logic [9:0] rom [0:8192];
	
	logic [9:0] ram_out;
	
	always_ff @(posedge clk)
		if (write & addr[13])
			ram[addr[12:0]] <= indata;
		else if (read & addr[13])
			ram_out         <= ram[addr[12:0]];
	
	assign outdata = read ? (addr[13] ? rom[addr[12:0]] : ram_out) : 'z;

endmodule