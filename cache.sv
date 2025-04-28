module cache #(
	parameter LINES      = 64,
				 WORDS      = 32,
				 DATA_WIDTH = 10,
				 ADDR_WIDTH = 13,
				 OFFSET     = $clog2(WORDS),
				 TAG        = ADDR_WIDTH - OFFSET,
				 WORDS_LEN  = $clog2(WORDS),
				 LINES_LEN  = $clog2(LINES)
) (
	input                                       clk,
	input                                       rst,
	input        [ADDR_WIDTH - 1:0]             addr,
	input                                       read,
	input                                       write,
	input        [DATA_WIDTH - 1:0]             write_data,
	output       [DATA_WIDTH - 1:0]             data,
	output                                      ready,
	
	output logic [ADDR_WIDTH - 1:0]             ram_addr,
	output logic                                ram_read,
	input  logic [DATA_WIDTH - 1:0]             ram_data_out,
	output logic                                ram_write,
	output logic [DATA_WIDTH - 1:0]             ram_data_in,
	
	output [1 + TAG + WORDS * DATA_WIDTH - 1:0] D_MEM [LINES],
	output [WORDS_LEN:0]                        D_DATACNT,
	output [LINES_LEN - 1:0]                    D_LASTSAVE [LINES],
	output [LINES_LEN - 1:0]                    D_INDEX,
	output [LINES_LEN - 1:0]                    D_WRITEINDEX
);

	typedef enum {
		IDLE,
		READ,
		LOAD
	} state_e;
	
	state_e state, next_state;

	logic hit;
	
	logic [1 + TAG + WORDS * DATA_WIDTH - 1:0] mem [LINES];
	
	logic [   TAG - 1:0] tag;
	logic [OFFSET - 1:0] offset;
	
	always_comb begin
		tag    = addr[ADDR_WIDTH - 1:OFFSET];
		offset = addr[    OFFSET - 1:0];
	end
	
	logic [DATA_WIDTH - 1:0] data_sel;
	logic [     WORDS_LEN:0] data_cnt;
	
	logic [ LINES_LEN - 1:0] last_save [LINES];
	logic [ LINES_LEN - 1:0] index;
	logic [ LINES_LEN - 1:0] write_index;
	
	always_comb begin
		data_sel    =   'z;
		write_index =   'z;
		hit         =  1'b0;
		
		if (read) begin
			for (int i = 0; i < LINES; i++) begin
				if (tag == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					data_sel = mem[i][DATA_WIDTH * (offset + 1) - 1 -: DATA_WIDTH];
					hit      = 1'b1;
				end
			end
		end
		else if (write) begin		
			for (int i = 0; i < LINES; i++) begin
				if (tag == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					write_index = LINES_LEN'(i);
					hit         = 1'b1;
				end
			end
		end
	end
	
	always_comb begin	
		next_state  = state;
		
		ram_addr    = 'z;
		ram_read    = '0;
		ram_write   = '0;
		ram_data_in = 'z;
	
		case (state)
			IDLE: if ((read || write) && ~hit)
						next_state = mem[index][TAG + WORDS * DATA_WIDTH] ? LOAD : READ;
			READ: if (data_cnt < WORDS) begin
						ram_addr    = { addr[ADDR_WIDTH - 1:OFFSET], OFFSET'(0) } + data_cnt;
						ram_read    = 1'b1;
					end
					else
						next_state  = IDLE;
			LOAD: if (data_cnt < WORDS) begin 
						ram_addr    = { mem[index][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH], OFFSET'(0) } + data_cnt;
						ram_data_in = mem[index][DATA_WIDTH * (data_cnt + 1) - 1 -: DATA_WIDTH];
						ram_write   = 1'd1;
					end
					else
						next_state  = READ;
		endcase
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst)
			data_cnt <= '0;
		else if (state == LOAD) begin
			if (data_cnt < WORDS)
				data_cnt <= data_cnt + 1'b1;
			else
				data_cnt <= '0;
		end
		else if (state == READ) begin
			if (data_cnt < WORDS)
				data_cnt <= data_cnt + 1'b1;
			else
				data_cnt <= '0;
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < LINES; i++)
				mem[i] <= '0;
		end
		else if (state == READ) begin
			if (data_cnt > 1'b0 && data_cnt < WORDS)
				mem[index][DATA_WIDTH * data_cnt - 1 -: DATA_WIDTH]         <= ram_data_out;
			else if (data_cnt == WORDS) begin
				mem[index][DATA_WIDTH * data_cnt - 1 -: DATA_WIDTH]         <= ram_data_out;
				mem[index][TAG + WORDS * DATA_WIDTH]                        <= 1'b1;
				mem[index][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] <= tag;
			end
		end
		else if (write && hit)
			mem[index][DATA_WIDTH * (offset + 1) - 1 -: DATA_WIDTH] <= write_data;
	end
	
	always_comb begin
		index = 'z;
		
		if (read || (write && ~hit)) begin
			for (int i = 1; i < LINES; i++)
				if (last_save[i] > last_save[index])
					index = LINES_LEN'(i);
		end
		else if (write && hit)
			index = write_index;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < LINES; i++)
				last_save[i] <= LINES_LEN'(LINES - 1 - i);
		end
		else if ((write && hit) || (state == READ && data_cnt == WORDS)) begin
			for (int i = 0; i < LINES; i++) begin
				if (last_save[i] < last_save[index])
					last_save[i] <= last_save[i] + 1'b1;
			end
			last_save[index] <= '0;
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst)
			state <= IDLE;
		else
			state <= next_state;
	end
	
	assign data         = data_sel;
	assign ready        = (read || write) && hit && data_cnt == '0;
	
	assign D_MEM        = mem;
	assign D_DATACNT    = data_cnt;
	assign D_LASTSAVE   = last_save;
	assign D_INDEX      = index;
	assign D_WRITEINDEX = write_index;

endmodule