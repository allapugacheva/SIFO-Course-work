module gpr (
	input        clk,
	input        rst,

	input        write,	
	input  [3:0] inaddr,
	input  [9:0] indata,
	
	input        read1,
	input  [3:0] outaddr1,
	output [9:0] outdata1,
	
	input        read2,
	input  [3:0] outaddr2,
	output [9:0] outdata2,
	
	input        read3,
	input  [3:0] outaddr3,
	output [9:0] outdata3,
	
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
			registers[inaddr] <= indata;
	
	assign outdata1 = read1 ? registers[outaddr1] : 'z;
	assign outdata2 = read2 ? registers[outaddr2] : 'z;
	assign outdata3 = read3 ? registers[outaddr3] : 'z;
	
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