`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Data Extend
// Tool Versions: Vivado 2017.4.1
// Description: Data Extension module
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  将Cache中Load的数据扩展成32�??
// 输入
    // data              cache读出的数�??
    // addr              字节地址
    // load_type         load的类�??
    // ALU_func          运算类型
// 输出
    // dealt_data        扩展完的数据
// 实验要求
    // 补全模块


`include "Parameters.v"

module DataExtend(
    input wire [31:0] data,
    input wire [1:0] addr,
    input wire [2:0] load_type,
    output reg [31:0] dealt_data
    );
    reg [7:0] LB_data;
    reg [15:0] LH_data;
    always@(*) begin
        case(addr)
        2'b11:LB_data <= data[31:24];
        2'b10:LB_data <= data[23:16];
        2'b01:LB_data <= data[15:8];
        2'b00:LB_data <= data[7:0];
        default:;
        endcase
    end
    always@(*) begin
        case(addr)
        2'b10:LH_data <= data[31:16];
        2'b00:LH_data <= data[15:0];
        default:;
        endcase
    end
    always@(*) begin
        case(load_type)
        `LB: dealt_data <= {{24{LB_data[7]}},LB_data[7:0]};
        `LH: dealt_data <= {{16{LH_data[15]}},LH_data[15:0]};
        `LW: dealt_data <= data;
        `LBU: dealt_data <= {24'b0,LB_data[7:0]};
        `LHU: dealt_data <= {16'b0,LH_data[15:0]};
        default:dealt_data <= 32'b0;
        endcase
    end
    // TODO: Complete this module

endmodule