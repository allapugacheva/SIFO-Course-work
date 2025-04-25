module gpr (
	input clk,
	input rst,
	
	input [3:0] addr,
	input [9:0] indata,
	
	input        read,
	input        write,
	
	output [9:0] outdata,

	output [9:0] D_REG1,
	output [9:0] D_REG2,
	output [9:0] D_REG3,
	output [9:0] D_REG4,
	output [9:0] D_REG5,
	output [9:0] D_REG6,
	output [9:0] D_REG7,
	output [9:0] D_REG8,
	output [9:0] D_REG9,
	output [9:0] D_REG10
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
	
	assign D_REG1  = registers[0];
	assign D_REG2  = registers[1];
	assign D_REG3  = registers[2];
	assign D_REG4  = registers[3];
	assign D_REG5  = registers[4];
	assign D_REG6  = registers[5];
	assign D_REG7  = registers[6];
	assign D_REG8  = registers[7];
	assign D_REG9  = registers[8];
	assign D_REG10 = registers[9];

endmodule