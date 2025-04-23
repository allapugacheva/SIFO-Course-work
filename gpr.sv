module gpr (
	input clk,
	input rst,
	
	input [3:0] addr,
	input [9:0] indata,
	
	input        read,
	input        write,
	
	output [9:0] outdata
);

	logic [9:0] registers [0:9];
	
	always_ff @(posedge clk or posedge rst)
		if (rst) begin
			for (int i = 0; i < 10; i++)
				registers[i] <= '0;
		end
		else if (write)
			registers[addr] <= indata;
	
	assign outdata = read ? registers[addr] : 'z;

endmodule