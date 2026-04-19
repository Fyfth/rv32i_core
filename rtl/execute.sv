module execute
import rv32i_pkg::*;
(
    input logic[31:0] rd1, rd2, 
    input logic[31:0] imm, 
    input logic[2:0] funct3, 
    input logic[6:0] funct7, 
    input logic[1:0] alu_op, 
    input logic alu_src, 
    input logic[1:0] forwardA,
    input logic[1:0] forwardB,
    input logic[31:0] ex_mem_result, //1 cycle forwarding 
    input logic[31:0] mem_wb_result, //2 cycle forwarding
    output logic [31:0] rd2_forwarded,
    output logic[31:0] alu_result, 
    output logic zero
);
    alu_ctrl_t alu_ctrl_sig; 

    alu_ctrl aluCtrl(.funct3(funct3),.funct7(funct7),.alu_op(alu_op),.alu_ctrl(alu_ctrl_sig)); 

    logic[31:0] b,b_reg; 
    logic[31:0] a; 
    always_comb begin
        case (forwardA)
            2'b00: a = rd1;              // regfile value
            2'b01: a = mem_wb_result;    // MEM/WB forward
            2'b10: a = ex_mem_result;    // EX/MEM forward
            default: a = rd1;
        endcase

        case (forwardB)
            2'b00: b_reg = rd2;
            2'b01: b_reg = mem_wb_result;
            2'b10: b_reg = ex_mem_result;
            default: b_reg = rd2;
        endcase
    end

    assign rd2_forwarded = b_reg;

    assign b = alu_src? imm:b_reg; 

    alu alu(.alu_ctrl(alu_ctrl_sig),.a(a), .b(b), .alu_result(alu_result), .zero(zero));

endmodule



