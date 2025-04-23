module cache #(
	parameter LINES      = 8,
				 WORDS      = 8,
				 DATA_WIDTH = 10,
				 ADDR_WIDTH = 14,
				 OFFSET     = $clog2(WORDS),
				 TAG        = ADDR_WIDTH - OFFSET,
				 WORDS_LEN  = $clog2(WORDS)
) (
	input                     clk,
	input                     rst,
	input  [ADDR_WIDTH - 1:0] addr,
	input                     read,
	input                     write,
	input  [DATA_WIDTH - 1:0] write_data,
	output                    hit,
	output [DATA_WIDTH - 1:0] data,
	output                    data_strob,
	
	output logic [ADDR_WIDTH - 1:0] ram_addr,
	output logic                    ram_read,
	input  logic [DATA_WIDTH - 1:0] ram_data_out,
	output logic                   ram_write,
	output logic [DATA_WIDTH - 1:0] ram_data_in,
	
	output logic [1 + TAG + WORDS * DATA_WIDTH - 1:0] _mem [0:LINES - 1],
	output [DATA_WIDTH - 1:0]                   _data_sel,
	output [$clog2(WORDS):0]                    _data_cnt,
	output logic [$clog2(WORDS) - 1:0]                _last_save [0:WORDS - 1],
	output [$clog2(WORDS) - 1:0]                _index,
	output [$clog2(WORDS) - 1:0]                _write_index
);

	typedef enum {
		IDLE,
		SHOW,
		READ,
		LOAD,
		SAVE
	} state_e;
	
	state_e state, next_state;

	logic [1 + TAG + WORDS * DATA_WIDTH - 1:0] mem [0:LINES - 1];
	
	logic [   TAG - 1:0] tag;
	logic [OFFSET - 1:0] offset;
	
	always_comb begin
		tag    = addr[ADDR_WIDTH - 1:OFFSET];
		offset = addr[    OFFSET - 1:0];
	end
	
	logic [DATA_WIDTH - 1:0] data_sel;
	logic [WORDS_LEN:0]      data_cnt;
	
	logic [WORDS_LEN - 1:0] last_save [0:WORDS - 1];
	logic [WORDS_LEN - 1:0] index;
	logic [WORDS_LEN - 1:0] write_index;
	
	
	assign _mem      = mem;
	assign _data_sel = data_sel;
	assign _data_cnt = data_cnt;
	assign _last_save = last_save;
	assign _index = index;
	assign _write_index = write_index;
	
	always_comb begin
		data_sel    = 'z;
		write_index = 'z;
		if (state == IDLE | state == SHOW | state == SAVE) begin
			if (read) begin
				for (int i = 0; i < LINES; i++) begin
					if (tag == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
						data_sel = mem[i][DATA_WIDTH * (offset + 1) - 1 -: DATA_WIDTH];
					end
				end
			end
			else if (write) begin		
				for (int i = 0; i < LINES; i++) begin
					if (tag == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
						write_index = WORDS_LEN'(i);
					end
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
			IDLE: if (read) begin
						if      (data_sel === 'z & mem[index][TAG + WORDS * DATA_WIDTH])
							next_state = LOAD;
						else if (data_sel === 'z & ~mem[index][TAG + WORDS * DATA_WIDTH])
							next_state = READ;
						else
							next_state = SHOW;
					end
					else if (write) begin						
						if      (write_index === 'z & mem[index][TAG + WORDS * DATA_WIDTH])
							next_state = LOAD;
						else if (write_index === 'z & ~mem[index][TAG + WORDS * DATA_WIDTH])
							next_state = READ;
						else
							next_state = SAVE;
					end
			SHOW: next_state = IDLE;
			READ: if (data_cnt < WORDS) begin
						ram_addr = {addr[ADDR_WIDTH - 1:OFFSET], OFFSET'(0)} + data_cnt;
						ram_read = 1'b1;
					end
					else if (read)
						next_state = SHOW;
					else
						next_state = SAVE;
			SAVE: next_state = IDLE;
			LOAD: if (data_cnt < WORDS) begin 
						ram_addr = {mem[index][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH], OFFSET'(0)} + data_cnt;
						ram_data_in = mem[index][DATA_WIDTH * (data_cnt + 1) - 1 -: DATA_WIDTH];
						ram_write = 1'd1;
					end
					else
						next_state = READ;
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
		end
		else if (state == IDLE)
			data_cnt <= '0;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < LINES; i++) begin
				mem[i] <= '0;
			end
		end
		else if (state == READ) begin
			if (data_cnt < WORDS)
				mem[index][DATA_WIDTH * (data_cnt + 1) - 1 -: DATA_WIDTH] <= ram_data_out;
			else begin
				mem[index][TAG + WORDS * DATA_WIDTH] <= 1'b1;
				mem[index][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] <= tag;
			end
		end
		else if (state == SAVE)
			mem[index][DATA_WIDTH * (offset + 1) - 1 -: DATA_WIDTH] <= write_data;
	end
	
	always_comb begin
		index = '0;
		
		if (read | (write & ~hit)) begin
			for (int i = 1; i < WORDS; i++) begin
				if (last_save[i] > last_save[index])
					index = WORDS_LEN'(i);
			end
		end
		else if (write & hit) begin
			index = write_index;
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < WORDS; i++) begin
				last_save[i] <= WORDS_LEN'(WORDS - 1 - i);
			end
		end
		else if ((state == SHOW & ~hit) | state == SAVE) begin
			for (int i = 0; i < WORDS; i++) begin
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
	
	assign data       = state == SHOW ? data_sel : 'z;
	assign hit        = (state == SHOW | state == SAVE) && data_cnt < WORDS;
	assign data_strob = state == SHOW;

endmodule