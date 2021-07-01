`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: PC ID Seg Reg
// Tool Versions: Vivado 2017.4.1
// Description: PC seg reg for IF\ID
// 
//////////////////////////////////////////////////////////////////////////////////


//  功能说明
    // IF\ID的PC段寄存器
// 输入
    // clk               时钟信号
    // PC_IF             PC寄存器传来的指令地址
    // bubbleD           ID阶段的bubble信号
    // flushD            ID阶段的flush信号
// 输出
    // PC_ID             传给下一段寄存器的PC地址
// 实验要求  
    // 无需修改

module PC_ID(
    input wire clk, bubbleD, flushD,
    input wire [31:0] PC_IF,
    output reg [31:0] PC_ID,
    input wire BTB_F,
    output reg BTB_D,
    input wire Branch_takenF,
    output reg Branch_takenD
    );

    initial PC_ID = 0;
    
    always@(posedge clk)
        if (!bubbleD) 
        begin
            if (flushD) begin
                PC_ID <= 0;
                BTB_D <= 0;
                Branch_takenD <=0;
            end
            else begin
                PC_ID <= PC_IF;
                BTB_D<=BTB_F;
                Branch_takenD<=Branch_takenF;
            end
        end
    
endmodule