module cu (
	input        clk,
	input        rst,
	
	input  [4:0] opcode,
	input        s,
	input        g,
	
	output logic resultSrc,
	
	output logic memWE,
	output logic memRE,
	
	output logic regWE,
	output logic regRE,
	
	output logic pcEn,
	
	output logic memAddrSrc,
	
	output logic op1RE,
	output logic op2RE,
	
	output logic RiHRE,
	output logic RiLRE,
	
	output logic pcSrc,
	
	output logic [1:0] instrWrite,
	
	output logic push,
	output logic pop,
	
	output logic [2:0] D_STATE,
	output logic       D_SF,
	output logic       D_GF
);

	enum logic [2:0] {
		FETCH_B1,
		FETCH_B2_R1,
		FETCH_B3_RIH,
		FETCH_RIL,
		FETCH_M_WAIT,
		FETCH_M_SAVE,
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
		memRE      = 1'b0;
		regWE      = 1'b0;
		regRE      = 1'b0;
		pcEn       = 1'b0;
		memAddrSrc = 1'b0;
		op1RE      = 1'b0;
		op2RE      = 1'b0;
		RiHRE      = 1'b0;
		RiLRE      = 1'b0;
		pcSrc      = 1'b0;
		instrWrite = 2'd3;
		push       = 1'b0;
		pop        = 1'b0;
	
		case (state)
			FETCH_B1: begin
				next_state = FETCH_B2_R1;
				memRE      = 1'b1;
				instrWrite = 2'd0;
				pcEn       = 1'b1;
				memAddrSrc = 1'b1;
			end
			FETCH_B2_R1: begin
				pcEn       = 1'b1;
				memRE      = 1'b1;
				memAddrSrc = 1'b1;
				instrWrite = 2'b1;
				
				if (   opcode == 5'b00001
					 || opcode == 5'b00010
					 || opcode == 5'b00011
					 || opcode == 5'b00101
					 || opcode == 5'b01000
					 || opcode == 5'b01010
					 || opcode == 5'b01100
					 || opcode == 5'b10001
					 || opcode == 5'b10010 ) begin
					regRE   = 1'b1;
					op1RE   = 1'b1;
				end
				
				next_state = FETCH_B3_RIH;
			end
			FETCH_B3_RIH: begin
				pcEn       = 1'b1;
				memRE      = 1'b1;
				memAddrSrc = 1'b1;
				instrWrite = 2'd2;
				
				if (   opcode == 5'b00010
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011 ) begin
					regRE      = 1'b1;
					RiHRE      = 1'b1;
				end
				
				next_state = FETCH_RIL;
			end
			FETCH_RIL: begin
			
				if (   opcode == 5'b00010
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011 ) begin
					regRE      = 1'b1;
					RiLRE      = 1'b1;
				end
				
				next_state = FETCH_M_WAIT;
			end
			FETCH_M_WAIT: begin
			
				if (   opcode == 5'b00000
					 || opcode == 5'b00110
					 || opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011
					 || opcode == 5'b01110
					 || opcode == 5'b01111
					 || opcode == 5'b10000
					 || opcode == 5'b10001 )
					memRE = 1'b1;
					
				if (   opcode == 5'b00111
					 || opcode == 5'b01001
					 || opcode == 5'b01011
					 || opcode == 5'b01000
					 || opcode == 5'b01010
					 || opcode == 5'b01100 ) begin
					regRE     = 1'b1;
					op2RE     = 1'b1;
				end
				
				next_state = FETCH_M_SAVE;
			end
			FETCH_M_SAVE: begin			
			
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
				
				next_state = FETCH_B1;
			
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
			state <= FETCH_B1;
		else
			state <= next_state;

endmodule