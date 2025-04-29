module cu (
	input        clk,
	input        rst,
	
	input        stall,
	
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
	output logic reg4RE,
	
	output logic pcEn,
	
	output logic op1RE,
	output logic op2RE,
	
	output logic RiRE,
	
	output logic pcSrc,
	
	output logic instrWrite,
	
	output logic push,
	output logic pop,
	
	output logic       D_SF,
	output logic       D_GF,
	output [4:0] D_OPCODES3,
	output [4:0] D_OPCODES4,
	output [3:0] D_VLD
);
	
	logic sf, gf;
	
	assign D_SF = sf;
	assign D_GF = gf;
	
	logic [4:0] opcode_s3, opcode_s4;
	logic [3:0] vld;
	
	assign D_OPCODES3 = opcode_s3;
	assign D_OPCODES4 = opcode_s4;
	assign D_VLD = vld;
	
	always_ff @ (posedge clk or posedge rst)
		if (rst) begin
			opcode_s3 <= '1;
			opcode_s4 <= '1;
		end
		else if (~stall) begin
			opcode_s3 <= opcode;
			opcode_s4 <= opcode_s3;
		end
		
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			vld <= 4'b0001;
		else if (~stall)
			vld <= { vld[2:0], 1'b1 };
	
	always_comb begin
		
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
		reg4RE     = 1'b0;
		pcEn       = 1'b0;
		op1RE      = 1'b0;
		op2RE      = 1'b0;
		RiRE       = 1'b0;
		pcSrc      = 1'b0;
		instrWrite = 1'b0;
		push       = 1'b0;
		pop        = 1'b0;
	
		if (vld[0]) begin
			mem1RE     = 1'b1;
			mem2RE     = 1'b1;
			mem3RE     = 1'b1;
			
			if (~stall) begin 
				instrWrite = 1'b1;
				pcEn       = 1'b1;
			end
		end

		if (vld[1]) begin
			if (   opcode == 5'b00010
				 || opcode == 5'b00110
				 || opcode == 5'b00111
				 || opcode == 5'b01001
				 || opcode == 5'b01011 ) begin
				reg1RE = 1'b1;
				reg2RE = 1'b1;
				RiRE   = 1'b1;
			end
		end

		if (vld[2]) begin
			if (   opcode_s3 == 5'b00001
				 || opcode_s3 == 5'b00010
				 || opcode_s3 == 5'b00011
				 || opcode_s3 == 5'b00101
				 || opcode_s3 == 5'b01000
				 || opcode_s3 == 5'b01010
				 || opcode_s3 == 5'b01100
				 || opcode_s3 == 5'b10001
				 || opcode_s3 == 5'b10010 ) begin
				reg3RE = 1'b1;
				op1RE  = 1'b1;
			end
			if (   opcode_s3 == 5'b00111
				 || opcode_s3 == 5'b01001
				 || opcode_s3 == 5'b01011
				 || opcode_s3 == 5'b01000
				 || opcode_s3 == 5'b01010
				 || opcode_s3 == 5'b01100 ) begin
				reg4RE = 1'b1;
				op2RE  = 1'b1;
			end
		
			if (   opcode_s3 == 5'b00000
				 || opcode_s3 == 5'b00110
				 || opcode_s3 == 5'b00111
				 || opcode_s3 == 5'b01001
				 || opcode_s3 == 5'b01011
				 || opcode_s3 == 5'b10001 )
				mem4RE = 1'b1;
				
			if (   opcode_s3 == 5'b00000
				 || opcode_s3 == 5'b00110
				 || opcode_s3 == 5'b00111
				 || opcode_s3 == 5'b01001
				 || opcode_s3 == 5'b01011 )
				op1RE = 1'b1;
			else if (opcode_s3 == 5'b10001)
				op2RE = 1'b1;
		end

		if (vld[3]) begin
			if ( opcode_s4 == 5'b00000 ) begin
				resultSrc = 1'b1;
				regWE     = 1'b1;
			end
			else if (   opcode_s4 == 5'b00001
						|| opcode_s4 == 5'b00010 ) begin
				resultSrc = 1'b1;
				memWE     = 1'b1;
			end
			else if (opcode_s4 == 5'b00011) begin
				push      = 1'b1;
				resultSrc = 1'b1;
			end
			else if (opcode_s4 == 5'b00100) begin
				pop       = 1'b1;
				regWE     = 1'b1;
			end
			else if (   opcode_s4 == 5'b00101
						|| opcode_s4 == 5'b01000
						|| opcode_s4 == 5'b01010
						|| opcode_s4 == 5'b01100
						|| opcode_s4 == 5'b10010 ) begin
				regWE     = 1'b1;
			end
			else if (   opcode_s4 == 5'b00110
						|| opcode_s4 == 5'b00111
						|| opcode_s4 == 5'b01001
						|| opcode_s4 == 5'b01011 ) begin
				memWE     = 1'b1;		
			end
			else if (   opcode_s4 == 5'b01110 ) begin
				pcEn      = 1'b1;
				pcSrc     = 1'b1;
			end
			else if (   opcode_s4 == 5'b01111 && sf ) begin
				pcEn      = 1'b1;
				pcSrc     = 1'b1;
			end
			else if (   opcode_s4 == 5'b10000 && gf ) begin
				pcEn      = 1'b1;
				pcSrc     = 1'b1;
			end
		end
	end
	
	always_ff @ (posedge clk or posedge rst)
		if (rst) begin
			sf <= 1'b0;
			gf <= 1'b0;
		end
		else begin
			if (   opcode_s4 == 5'b00101
				 || opcode_s4 == 5'b00110
				 || opcode_s4 == 5'b00111
				 || opcode_s4 == 5'b01000
				 || opcode_s4 == 5'b01001
				 || opcode_s4 == 5'b01010
				 || opcode_s4 == 5'b01011
				 || opcode_s4 == 5'b01100
				 || opcode_s4 == 5'b10010 )
				sf <= s;
			if (   opcode_s4 == 5'b10001 )
				gf <= g;
		end
	
//	always_ff @ (posedge clk or posedge rst)
//		if (rst)
//			state <= FETCH_COMM;
//		else
//			state <= next_state;

endmodule