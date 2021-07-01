module CSRRegisterFile(
    input wire clk,
    input wire rst,
    input wire csr_write_en;
    input wire [31:0] csr_addr,
    input wire [31:0] csr_write_data,
    output wire [31:0] csr_out_data
    );

    reg [31:0] reg_file[31:1];
    wire [4:0] dealt_addr;
    integer i;
    
    // init register file
    initial
    begin
        for(i = 1; i < 32; i = i + 1) 
            reg_file[i][31:0] <= 32'b0;
    end
    assign dealt_addr = csr_addr[4:0];
    assign csr_out_data = reg_file[dealt_addr];
    always@(negedge clk or posedge rst) 
    begin 
        if (rst)
            for (i = 1; i < 32; i = i + 1) 
                reg_file[i][31:0] <= 32'b0;
        else if(csr_write_en && (csr_write_data != 32'b0))
            reg_file[dealt_addr] <= csr_write_data;   
    end
endmodule
