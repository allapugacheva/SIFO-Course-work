module cu (
	input        clk,
	input        rst,
	
	input  [4:0] opcode,
	input        s,
	input        g,
	
	output logic resultSrc,
	
	output logic memWE,
	output logic mem1RE,
	output logic mem2RE,
	output logic mem3RE,
	output logic mem4RE,
	
	output logic regWE,
	output logic reg1RE,
	output logic reg2RE,
	output logic reg3RE,
	
	output logic pcEn,
	
	output logic op1RE,
	output logic op2RE,
	
	output logic RiRE,
	
	output logic pcSrc,
	
	output logic instrWrite,
	
	output logic push,
	output logic pop,
	
	output logic [2:0] D_STATE,
	output logic       D_SF,
	output logic       D_GF
);

	enum logic [2:0] {
		FETCH_COMM,
		FETCH_REG,
		MEM_WAIT,
		MEM_SAVE,
		EXECUTE
		
	} state, next_state;
	
	assign D_STATE = state;
	
	logic sf, gf;
	
	assign D_SF = sf;
	assign D_GF = gf;
	
	always_comb begin
		next_state = state;
		
		resultSrc  = 1'b0;
		memWE      = 1'b0;
		mem1RE     = 1'b0;
		mem2RE     = 1'b0;
		mem3RE     = 1'b0;
		mem4RE     = 1'b0;
		regWE      = 1'b0;
		reg1RE     = 1'b0;
		reg2RE     = 1'b0;
		reg3RE     = 1'b0;
		pcEn       = 1'b0;
		op1RE      = 1'b0;
		op2RE      = 1'b0;
		RiRE      = 1'b0;
		pcSrc      = 1'b0;
		instrWrite = 1'b0;
		push       = 1'b0;
		pop        = 1'b0;
	
		case (state)
		
			FETCH_COMM: begin
				next_state = FETCH_REG;
				mem1RE     = 1'b1;
				mem2RE     = 1'b1;
				mem3RE     = 1'b1;
				instrWrite = 1'b1;
				pcEn       = 1'b1;
			end
			FETCH_REG: begin
				
				if (   opcode == 5'b00010
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011 ) begin
					reg2RE = 1'b1;
					reg3RE = 1'b1;
					RiRE   = 1'b1;
				end
				if (   opcode == 5'b00001
					 || opcode == 5'b00010
					 || opcode == 5'b00011
					 || opcode == 5'b00101
					 || opcode == 5'b01000
					 || opcode == 5'b01010
					 || opcode == 5'b01100
					 || opcode == 5'b10001
					 || opcode == 5'b10010 ) begin
					reg1RE = 1'b1;
					op1RE  = 1'b1;
				end
				if (   opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011 ) begin
					reg1RE = 1'b1;
					op2RE  = 1'b1;
				end
				if (   opcode == 5'b01000
					 || opcode == 5'b01010
					 || opcode == 5'b01100 ) begin
					reg2RE = 1'b1;
					op2RE  = 1'b1;
				end
				
				next_state = MEM_WAIT;
			end
			MEM_WAIT: begin
				if (   opcode == 5'b00000
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011
					 || opcode == 5'b01110
					 || opcode == 5'b01111
					 || opcode == 5'b10000
					 || opcode == 5'b10001 )
					mem4RE = 1'b1;
			
				next_state = MEM_SAVE;
			end
			MEM_SAVE: begin
				if (   opcode == 5'b00000
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011
					 || opcode == 5'b01110
					 || opcode == 5'b01111
					 || opcode == 5'b10000 )
					op1RE = 1'b1;
				else if (opcode == 5'b10001)
					op2RE = 1'b1;
				
				next_state = EXECUTE;
			end
			EXECUTE: begin
			
				if ( opcode == 5'b00000 ) begin
					resultSrc = 1'b1;
					regWE     = 1'b1;
				end
				else if (   opcode == 5'b00001
							|| opcode == 5'b00010 ) begin
					resultSrc = 1'b1;
					memWE     = 1'b1;
				end
				else if (opcode == 5'b00011) begin
					push      = 1'b1;
					resultSrc = 1'b1;
				end
				else if (opcode == 5'b00100) begin
					pop       = 1'b1;
					regWE     = 1'b1;
				end
				else if (   opcode == 5'b00101
							|| opcode == 5'b01000
							|| opcode == 5'b01010
							|| opcode == 5'b01100
							|| opcode == 5'b10010 ) begin
					regWE     = 1'b1;
				end
				else if (   opcode == 5'b00110
							|| opcode == 5'b00111
							|| opcode == 5'b01001
							|| opcode == 5'b01011 ) begin
					memWE     = 1'b1;		
				end
				else if (   opcode == 5'b01110 ) begin
					pcEn      = 1'b1;
					pcSrc     = 1'b1;
				end
				else if (   opcode == 5'b01111 && sf ) begin
					pcEn      = 1'b1;
					pcSrc     = 1'b1;
				end
				else if (   opcode == 5'b10000 && gf ) begin
					pcEn      = 1'b1;
					pcSrc     = 1'b1;
				end
				
				next_state = FETCH_COMM;
			end
		
		endcase
	end
	
	always_ff @ (posedge clk or posedge rst)
		if (rst) begin
			sf <= 1'b0;
			gf <= 1'b0;
		end
		else if (state == EXECUTE) begin
			if (   opcode == 5'b00101
				 || opcode == 5'b00110
				 || opcode == 5'b00111
				 || opcode == 5'b01000
				 || opcode == 5'b01001
				 || opcode == 5'b01010
				 || opcode == 5'b01011
				 || opcode == 5'b01100
				 || opcode == 5'b10010 )
				sf <= s;
			if (   opcode == 5'b10001 )
				gf <= g;
		end
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			state <= FETCH_COMM;
		else
			state <= next_state;

endmodule