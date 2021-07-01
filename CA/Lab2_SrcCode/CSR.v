module CSR(
    input wire clk,
    input wire rst,
    input wire [31:0] csr_addr,
    input wire [2:0] csr_func,
    input wire [31:0] csr_data,
    input wire csr_sel,
    output wire [31:0] csr_out_data
    );

    reg [31:0] reg_file[31:0];
    wire [4:0] dealt_addr;
    wire [31:0] result1,result2;
    reg [31:0] temp;
    reg [31:0]debug;
    integer i;
    
    // init register file
    initial
    begin
        for(i = 1; i < 32; i = i + 1) 
            reg_file[i][31:0] <= 32'b0;
        temp <= 32'b0;
    end
    assign dealt_addr = csr_addr[4:0];
    assign result1 = csr_data |  reg_file[dealt_addr];
    assign result2 = ~csr_data &  reg_file[dealt_addr];
    assign csr_out_data = temp;
    always@(negedge clk or posedge clk)begin
        temp <=reg_file[dealt_addr];
    end
    always@(negedge clk or posedge rst) 
    begin 
        debug <=(csr_func[1] == 1'b0) ? csr_data:
                                       ((csr_func[0] == 1'b0) ? result1:result2);   
        if (rst)
            for (i = 0; i < 32; i = i + 1) 
                reg_file[i][31:0] <= 32'b0;
        else if((csr_sel == 1'b1) && (dealt_addr != 5'b0))
            reg_file[dealt_addr] <= (csr_func[1] == 1'b0) ? csr_data:
                                                          ((csr_func[0] == 1'b0) ? result1:result2);   
    end
endmodule
