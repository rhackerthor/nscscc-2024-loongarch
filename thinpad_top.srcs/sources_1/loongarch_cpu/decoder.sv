module decoder_4_16 (
	input  logic [ 3:0] in,
	output logic [15:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 16; i = i + 1) begin : gen_for_dec_4_16
		assign out[i] = (in == i);
	end endgenerate

endmodule

module decoder_5_32 (
	input  logic [ 4:0] in,
	output logic [31:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 32; i = i + 1) begin : gen_for_dec_5_32
		assign out[i] = (in == i);
	end endgenerate

endmodule

module decoder_6_64 (
	input  logic [ 5:0] in,
	output logic [63:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 64; i = i + 1) begin : gen_for_dec_6_64
		assign out[i] = (in == i);
	end endgenerate

endmodule