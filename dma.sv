module dma (
	input         clk,
	input         rst,
	
	output        req,
	output [13:0] addr,
	
	input         grant,
	input  [ 9:0] indata,
	
	output [ 1:0] D_STATE,
	output [ 9:0] D_DATA
);

	enum logic [1:0] {
		IDLE,
		WAIT,
		READ
	} state, next_state;

	logic [12:0] random_addr;
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			random_addr <= 13'b1;
		else if (state == IDLE)
			random_addr <= { random_addr[11:0], random_addr[11] ^ random_addr[7] ^ random_addr[3] };
		
	assign addr = { 1'b0, random_addr };
	
	logic [ 4:0] req_reg;
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			req_reg <= 5'b1;
		else if (next_state == IDLE)
			req_reg <= { req_reg[3:0], req_reg[4] };
			
	assign req = req_reg[4];
	
	logic [ 9:0] data;
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			data <= '0;
		else if (state == READ)
			data <= indata;		
	
	always_comb begin
	
		next_state = state;
		
		case (state)
			IDLE: if (req_reg[4]) next_state = WAIT;
			WAIT: if (grant)      next_state = READ;
			READ:                 next_state = IDLE;
		endcase
		
	end
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			state <= IDLE;
		else
			state <= next_state;
	
	assign D_STATE = state;
	assign D_DATA  = data;
	
endmodule