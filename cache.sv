module cache #(
	parameter LINES      = 64,
				 WORDS      = 32,
				 DATA_WIDTH = 10,
				 ADDR_WIDTH = 14,
				 OFFSET     = $clog2(WORDS),
				 TAG        = ADDR_WIDTH - OFFSET,
				 WORDS_LEN  = $clog2(WORDS),
				 LINES_LEN  = $clog2(LINES)
) (
	input                           clk,
	input                           rst,
	
	input                           grant,
	
	input                           write,
	input        [ADDR_WIDTH - 1:0] inaddr,
	input        [DATA_WIDTH - 1:0] indata,
	output                          inready,
	
	input                           read1,
	input        [ADDR_WIDTH - 1:0] outaddr1,
	output       [DATA_WIDTH - 1:0] outdata1,
	output                          outready1,
	
	input                           read2,
	input        [ADDR_WIDTH - 1:0] outaddr2,
	output       [DATA_WIDTH - 1:0] outdata2,
	output                          outready2,
	
	input                           read3,
	input        [ADDR_WIDTH - 1:0] outaddr3,
	output       [DATA_WIDTH - 1:0] outdata3,
	output                          outready3,
	
	input                           read4,
	input        [ADDR_WIDTH - 1:0] outaddr4,
	output       [DATA_WIDTH - 1:0] outdata4,
	output                          outready4,
	
	output logic [ADDR_WIDTH - 1:0] ram_addr,
	output logic                    ram_read,
	input  logic [DATA_WIDTH - 1:0] ram_data_out,
	output logic                    ram_write,
	output logic [DATA_WIDTH - 1:0] ram_data_in,
	
	output       [     WORDS_LEN:0] D_DATACNT,
	output       [ LINES_LEN - 1:0] D_INDEX,
	output       [ LINES_LEN - 1:0] D_WRITEINDEX
);

	typedef enum {
		IDLE,
		READ,
		LOAD
	} state_e;
	
	state_e state, next_state;

	logic hitw, hitr1, hitr2, hitr3, hitr4;
	
	logic [1 + TAG + WORDS * DATA_WIDTH - 1:0] mem [LINES];
	
	logic [   TAG - 1:0] tagw, tagr1, tagr2, tagr3, tagr4;
	logic [OFFSET - 1:0] offsetw, offsetr1, offsetr2, offsetr3, offsetr4;
	
	always_comb begin
		tagw     = inaddr  [ADDR_WIDTH - 1:OFFSET];
		tagr1    = outaddr1[ADDR_WIDTH - 1:OFFSET];
		tagr2    = outaddr2[ADDR_WIDTH - 1:OFFSET];
		tagr3    = outaddr3[ADDR_WIDTH - 1:OFFSET];
		tagr4    = outaddr4[ADDR_WIDTH - 1:OFFSET];
		
		offsetw  = inaddr  [    OFFSET - 1:0];
		offsetr1 = outaddr1[OFFSET - 1:0];
		offsetr2 = outaddr2[OFFSET - 1:0];
		offsetr3 = outaddr3[OFFSET - 1:0];
		offsetr4 = outaddr4[OFFSET - 1:0];
	end
	
	logic [DATA_WIDTH - 1:0] data_sel1, data_sel2, data_sel3, data_sel4;
	logic [     WORDS_LEN:0] data_cnt;
	
	logic [ LINES_LEN - 1:0] last_save [LINES];
	logic [ LINES_LEN - 1:0] index;
	logic [ LINES_LEN - 1:0] write_index;
	
	logic [ADDR_WIDTH - 1:0] selected_addr;
	logic [       TAG - 1:0] selected_tag;
	
	always_comb begin
		selected_addr = 'z;
		selected_tag  = 'z;
		
		casez ({write && ~hitw, read1 && ~hitr1, read2 && ~hitr2, read3 && ~hitr3, read4 && ~hitr4})
			5'b1????: begin selected_addr = inaddr;   selected_tag = tagw;  end
			5'b01???: begin selected_addr = outaddr1; selected_tag = tagr1; end
			5'b001??: begin selected_addr = outaddr2; selected_tag = tagr2; end
			5'b0001?: begin selected_addr = outaddr3; selected_tag = tagr3; end
			5'b00001: begin selected_addr = outaddr4; selected_tag = tagr4; end
		endcase
	end
	
	always_comb begin
		write_index = 'z;
		data_sel1   = 'z;
		data_sel2   = 'z;
		data_sel3   = 'z;
		data_sel4   = 'z;
		
		hitw        = 1'b0;
		hitr1       = 1'b0;
		hitr2       = 1'b0;
		hitr3       = 1'b0;
		hitr4       = 1'b0;
		
		if (read1)
			for (int i = 0; i < LINES; i++)
				if (tagr1 == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					data_sel1 = mem[i][DATA_WIDTH * (offsetr1 + 1) - 1 -: DATA_WIDTH];
					hitr1     = 1'b1;
				end
		if (read2)
			for (int i = 0; i < LINES; i++)
				if (tagr2 == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					data_sel2 = mem[i][DATA_WIDTH * (offsetr2 + 1) - 1 -: DATA_WIDTH];
					hitr2     = 1'b1;
				end
		if (read3)
			for (int i = 0; i < LINES; i++)
				if (tagr3 == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					data_sel3 = mem[i][DATA_WIDTH * (offsetr3 + 1) - 1 -: DATA_WIDTH];
					hitr3     = 1'b1;
				end
		if (read4)
			for (int i = 0; i < LINES; i++)
				if (tagr4 == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					data_sel4 = mem[i][DATA_WIDTH * (offsetr4 + 1) - 1 -: DATA_WIDTH];
					hitr4     = 1'b1;
				end
		if (write) begin		
			for (int i = 0; i < LINES; i++) begin
				if (tagw  == mem[i][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] & mem[i][TAG + WORDS * DATA_WIDTH]) begin
					write_index = LINES_LEN'(i);
					hitw        = 1'b1;
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
			IDLE: if ((write && ~hitw) || (read1 && ~hitr1) || (read2 && ~hitr2) || (read3 && ~hitr3) || (read4 && ~hitr4))
						next_state = mem[index][TAG + WORDS * DATA_WIDTH] ? LOAD : READ;
			READ: if (data_cnt < WORDS) begin
						ram_addr    = { selected_addr[ADDR_WIDTH - 1:OFFSET], OFFSET'(0) } + data_cnt;
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
		else if (grant && state == READ) begin
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
		else begin
			if (grant && state == READ) begin
				if (data_cnt > 1'b0 && data_cnt < WORDS)
					mem[index][DATA_WIDTH * data_cnt - 1 -: DATA_WIDTH]         <= ram_data_out;
				else if (data_cnt == WORDS) begin
					mem[index][DATA_WIDTH * data_cnt - 1 -: DATA_WIDTH]         <= ram_data_out;
					mem[index][TAG + WORDS * DATA_WIDTH]                        <= 1'b1;
					mem[index][TAG + WORDS * DATA_WIDTH - 1:WORDS * DATA_WIDTH] <= selected_tag;
				end
			end
			if (state == IDLE && write && hitw)
				mem[write_index][DATA_WIDTH * (offsetw + 1) - 1 -: DATA_WIDTH] <= indata;
		end
	end
	
	always_comb begin
		index = '0;
		
		for (int i = 1; i < LINES; i++)
			if (last_save[i] > last_save[index])
				index = LINES_LEN'(i);
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < LINES; i++)
				last_save[i] <= LINES_LEN'(LINES - 1 - i);
		end
		else if (state == IDLE && write && hitw) begin
			for (int i = 0; i < LINES; i++) begin
				if (last_save[i] < last_save[write_index])
					last_save[i] <= last_save[i] + 1'b1;
			end
			last_save[write_index] <= '0;
		end
		else if (state == READ && data_cnt == WORDS) begin
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

	assign inready      = write && hitw  && state == IDLE;
	assign outready1    = read1 && hitr1 && state == IDLE;
	assign outready2    = read2 && hitr2 && state == IDLE;
	assign outready3    = read3 && hitr3 && state == IDLE;
	assign outready4    = read4 && hitr4 && state == IDLE;
	
	assign outdata1     = data_sel1;
	assign outdata2     = data_sel2;
	assign outdata3     = data_sel3;
	assign outdata4     = data_sel4;
	
	assign D_DATACNT    = data_cnt;
	assign D_INDEX      = index;
	assign D_WRITEINDEX = write_index;

endmodule