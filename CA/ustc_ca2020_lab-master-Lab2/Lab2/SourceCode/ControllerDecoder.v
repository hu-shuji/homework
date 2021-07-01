`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Controller Decoder
// Tool Versions: Vivado 2017.4.1
// Description: Controller Decoder Module
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  对指令进行译码，将其翻译成控制信号，传输给各个部�???
// 输入
    // Inst              待译码指�???
// 输出
    // jal               jal跳转指令
    // jalr              jalr跳转指令
    // op2_src           ALU的第二个操作数来源�?�为1时，op2选择imm，为0时，op2选择reg2
    //· ALU_func          ALU执行的运算类�???
    //· br_type           branch的判断条件，可以是不进行branch
    // load_npc          写回寄存器的值的来源（PC或�?�ALU计算结果�???, load_npc == 1时�?�择PC
    // wb_select         写回寄存器的值的来源（Cache内容或�?�ALU计算结果），wb_select == 1时�?�择cache内容
    //· load_type         load类型
    //· src_reg_en        指令中src reg的地�???是否有效，src_reg_en[1] == 1表示reg1被使用到了，src_reg_en[0]==1表示reg2被使用到�???
    //· reg_write_en      通用寄存器写使能，reg_write_en == 1表示�???要写回reg
    //· cache_write_en    按字节写入data cache
    //· imm_type          指令中立即数类型
    // alu_src1          alu操作�???1来源，alu_src1 == 0表示来自reg1，alu_src1 == 1表示来自PC
    // alu_src2          alu操作�???2来源，alu_src2 == 2’b00表示来自reg2，alu_src2 == 2'b01表示来自reg2地址，alu_src2 == 2'b10表示来自立即�???
// 实验要求
    // 补全模块


`include "Parameters.v"   
        module ControllerDecoder(
            input wire [31:0] inst,
            output wire jal,
            output wire jalr,
            output wire op2_src,
            output reg [3:0] ALU_func,
            output reg [2:0] br_type,
            output wire load_npc,
            output wire wb_select,
            output reg [2:0] load_type,
            output reg [1:0] src_reg_en,
            output reg reg_write_en,
            output reg [3:0] cache_write_en,
            output wire alu_src1,
            output wire [1:0] alu_src2,
            output reg [2:0] imm_type,
            output wire csr_sel,
            output wire csr_datasel,
            output wire [2:0] csr_func
            );
            wire [6:0] op;
            wire [2:0] func3;
            wire [6:0] func7;
            initial begin
                ALU_func = 4'b0;
                br_type = 3'b0;
                load_type = 3'b0;
                src_reg_en = 2'b0;
                reg_write_en = 0;
                cache_write_en = 4'b0;
                imm_type = 3'b0;
            end

            assign op2_src = (inst[6:0] == 7'b0110011 ? 1'b0:1'b1);
            assign op = inst[6:0];
            assign func3 = inst[14:12];
            assign func7 = inst[31:25];
            assign jal = (op == 7'b1101111);
            assign jalr = (op == 7'b1100111);
            assign load_npc = jal | jalr;
            assign wb_select = (op == 7'b0000011);//ld
            assign alu_src1 = (op == 7'b0010111);//auipc
            assign alu_src2 = ( (op==7'b0010011)&&(func3[1:0]==2'b01) )?(2'b01):(((op==7'b0110011)||(op==7'b1100011))?2'b00:2'b10);//移位指令/ R/B指令
            
            //csr
            assign csr_func = func3[2:0];
            assign csr_sel = (op == 7'b1110011)? 1'b1:1'b0;
            assign csr_datasel = (op == 7'b1110011 & func3[2] == 1'b1 ) ? 1'b1:1'b0;

            //csr
            
            always@(*)begin
                case(op)
                    7'b0110111: //lui
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b00;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `UTYPE;
                        ALU_func <= `LUI;
                    end
                    7'b0010111://auipc
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b00;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `UTYPE;
                        ALU_func <= `ADD;
                    end
                    7'b1100011://BTYPE
                    begin
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b11;
                        reg_write_en <= 0;
                        cache_write_en <= 4'b0000;
                        imm_type <= `BTYPE;
                        ALU_func <= `ADD;
                        case(func3)
                            3'b000: br_type <= `BEQ;
                            3'b001: br_type <= `BNE;
                            3'b100: br_type <= `BLT;
                            3'b101: br_type <= `BGE;
                            3'b110: br_type <= `BLTU;
                            3'b111: br_type <= `BGEU;
                            default:br_type <=`NOBRANCH;
                        endcase                  
                    end
                    7'b0000011://ld
                    begin
                        br_type <= `NOBRANCH;
                        src_reg_en <= 2'b10;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `ITYPE;
                        ALU_func <= `ADD;
                        case(func3)
                        3'b000: load_type <= `LB;
                        3'b001: load_type <= `LH;
                        3'b010: load_type <= `LW;
                        3'b100: load_type <= `LBU;
                        3'b101: load_type <= `LHU;
                        default:;
                        endcase                
                    end
                    7'b0100011://store
                    begin
                        br_type <= `NOBRANCH;
                        src_reg_en <= 2'b11;
                        reg_write_en <= 0;
                        imm_type <= `STYPE;
                        load_type <= `NOREGWRITE;
                        case(func3)
                        3'b000: cache_write_en <= 4'b0001;//sb
                        3'b001: cache_write_en <= 4'b0011;//sh
                        3'b010: cache_write_en <= 4'b1111;//sw
                        default:;
                        endcase
                     end
                    7'b0010011://ITYPE
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b10;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `ITYPE;
                        case(func3)
                            3'b000:ALU_func<=`ADD;  
                            3'b001:ALU_func<=`SLL;  
                            3'b010:ALU_func<=`SLT;  
                            3'b011:ALU_func<=`SLTU;  
                            3'b100:ALU_func<=`XOR;   
                            3'b101:
                            begin
                                if(func7 == 7'b0100000)
                                    ALU_func<=`SRA;  
                                else
                                    ALU_func<=`SRL;  
                            end
                            3'b110:ALU_func<=`OR;   
                            3'b111:ALU_func<=`AND;
                            default: ;                                              
                    endcase
                    end
                    7'b0110011://RTYPE
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b11;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `RTYPE;
                        case(func3)
                        3'b000:
                        begin
                            if(func7 == 7'b0000000)
                                ALU_func <= `ADD;
                            else
                                ALU_func <= `SUB;
                        end
                        3'b001: ALU_func <= `SLL;
                        3'b010: ALU_func <= `SLT;
                        3'b011: ALU_func <= `SLTU;
                        3'b100: ALU_func <= `XOR;
                        3'b101:
                        begin
                            if(func7 == 7'b0000000)
                                ALU_func <= `SRL;
                            else
                                ALU_func <= `SRA;
                        end
                        3'b110: ALU_func <= `OR;
                        3'b111: ALU_func <= `AND;
                        default: ;
                        endcase
                        
                    end
                    7'b1101111://jal
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b00;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `JTYPE;
                        ALU_func <= `ADD; 
                    end
                    7'b1100111://jalr
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= 2'b10;
                        reg_write_en <= 1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `ITYPE;
                        ALU_func <= `ADD;           
                    end
                    7'b1110011://csr
                    begin
                        br_type <= `NOBRANCH;
                        load_type <= `NOREGWRITE;
                        src_reg_en <= (func3[2] == 1'b0) ? 2'b10:2'b00;
                        reg_write_en <= 1'b1;
                        cache_write_en <= 4'b0000;
                        imm_type <= `ITYPE;
                        ALU_func <= `ADD;
                    end
                default://空指�??
                begin
                    br_type <= `NOBRANCH;
                    load_type <= `NOREGWRITE;
                    src_reg_en <= 2'b00;
                    reg_write_en <= 0;
                    cache_write_en <= 4'b0000;
                    imm_type <= `ITYPE;
                    ALU_func <= `ADD; 
                end
                endcase
            end
        endmodule