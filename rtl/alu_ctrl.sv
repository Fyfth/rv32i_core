module alu_ctrl
import rv32i_pkg::*;
(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [1:0] alu_op, 
    output alu_ctrl_t alu_ctrl
); 
    always_comb begin
        case(alu_op)  
            default: alu_ctrl = ALU_ADD;
            2'b00: begin 
                alu_ctrl = ALU_ADD; //0= ADD
            end
            2'b01: begin 
                alu_ctrl = ALU_SUB; //1 = SUB
            end
            2'b10: begin 
                case(funct3)  
                    default: alu_ctrl = ALU_ADD;
                    3'b000: alu_ctrl = (funct7==7'b0100000) ? ALU_SUB : ALU_ADD; //1 = sub, 0 = add
                    3'b001: begin 
                        alu_ctrl = ALU_SLL; // 2= sll
                    end 
                    3'b010: begin 
                        alu_ctrl = ALU_SLT; // 3= slt
                    end
                    3'b011: begin 
                        alu_ctrl = ALU_SLTU; // 4 = sltu
                    end
                    3'b100: begin 
                        alu_ctrl = ALU_XOR; // 5 = xor
                    end //7 = sra , 6 = srl
                    3'b101: alu_ctrl = (funct7==7'b0100000) ? ALU_SRA : ALU_SRL; //7 = sra , 6 = srl
                    3'b110: begin 
                        alu_ctrl = ALU_OR; //8 = or 
                    end 
                    3'b111:begin
                        alu_ctrl = ALU_AND; //9 = and
                    end
                endcase
            end
        endcase
    end
endmodule
                













