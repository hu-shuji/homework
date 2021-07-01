
module BTB(
	input  clk, rst,

	input [31:0] Branch_PC,				
	output reg Branch_predicted,			
	output reg [31:0] Branch_predicted_PC,				
	input [31:0] ex_PC,				
	input [31:0] ex_predicted_PC,	
   input wire BTB_E,
   input wire Branch_E,
   input BHT_update,
   output reg Branch_taken
);
parameter  BUFFER_ADDR_LEN = 12;
localparam TAG_ADDR_LEN = 32 - BUFFER_ADDR_LEN - 2;	
localparam BUFFER_SIZE = 1 << BUFFER_ADDR_LEN;	

wire update_req = BTB_E ^ Branch_E;
reg [TAG_ADDR_LEN - 1 : 0] PCTag [0 : BUFFER_SIZE - 1];
reg [31 : 0] PredictPC [0 : BUFFER_SIZE - 1];
reg PredictStateBit	[0 : BUFFER_SIZE - 1];

wire [BUFFER_ADDR_LEN - 1 : 0] Branch_buffer_addr;
wire [TAG_ADDR_LEN - 1 : 0] Branch_tag_addr;
wire [1 : 0] Branch_word_addr; 

wire [BUFFER_ADDR_LEN - 1 : 0] ex_buffer_addr;
wire [TAG_ADDR_LEN - 1 : 0] ex_tag_addr;
wire [1 : 0] ex_word_addr; 
assign {Branch_tag_addr, Branch_buffer_addr, Branch_word_addr} = Branch_PC;
assign {ex_tag_addr, ex_buffer_addr, ex_word_addr} = ex_PC;

always @ (*) begin 
	if(PCTag[Branch_buffer_addr] == Branch_tag_addr && PredictStateBit[Branch_buffer_addr])
      Branch_predicted <= 1'b1;
	else
		Branch_predicted <= 1'b0;
	Branch_predicted_PC <= PredictPC[Branch_buffer_addr];
end
always @ (posedge clk or posedge rst) begin
	if(rst) begin
		for(integer i = 0; i < BUFFER_SIZE; i = i + 1) begin
			PCTag[i] <= 0;
			PredictPC[i] <= 0;
			PredictStateBit[i] <= 1'b0;
		end
		Branch_predicted <= 1'b0;
		Branch_predicted_PC <= 0;
      Branch_taken = 1;
		Branch_predicted <= 1'b0;
	end 
	else begin//更新
		if(update_req) begin
			PCTag[ex_buffer_addr] <= ex_tag_addr;
			PredictPC[ex_buffer_addr] <= ex_predicted_PC;
			PredictStateBit[ex_buffer_addr] <= Branch_E;
		end
	end
end

//BHT
reg [1 : 0] state [BUFFER_SIZE-1:0];
always @ (*) begin
	Branch_taken <= (state[Branch_buffer_addr] >= 2'b10);
end
always @ (posedge clk or posedge rst) begin
	if(rst) begin
		for(integer i = 0; i < BUFFER_SIZE; i = i + 1) begin
			state[i] <= 2'b00;
		end
		Branch_taken <= 0;
	end else begin
		if(BHT_update) begin
			if(Branch_E) begin
				if(state[ex_buffer_addr] != 2'b11) 
					state[ex_buffer_addr] <= state[ex_buffer_addr] + 2'b01;
				else
					state[ex_buffer_addr] <= state[ex_buffer_addr];
			end else begin
				if(state[ex_buffer_addr] != 2'b00) 
					state[ex_buffer_addr] <= state[ex_buffer_addr] - 2'b01;
				else
					state[ex_buffer_addr] <= state[ex_buffer_addr];
			end
		end
	end
end










endmodule





