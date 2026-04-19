
module alu
import rv32i_pkg::*;
(
    input alu_ctrl_t alu_ctrl, 
    input logic[31:0] a, b, 
    output logic [31:0] alu_result, 
    output logic zero
); 
    always_comb begin
        case(alu_ctrl)  
            ALU_ADD: alu_result = a+b; 
            ALU_SUB: alu_result = a-b; 
            ALU_SLL: alu_result = a<<b; //Shift Left Logical
            ALU_SLT: alu_result = ($signed(a)<$signed(b))? 32'd1:32'd0; 
            ALU_SLTU:alu_result = ((a)<(b))? 32'd1:32'd0; 
            ALU_XOR: alu_result = a^b; 
            ALU_SRL: alu_result = a>>b; //shift right logical
            ALU_SRA: alu_result = $signed(a) >>> b[4:0];//Shift right arithmetic 
            ALU_OR: alu_result = a|b; 
            ALU_AND: alu_result = a&b; 
            default:  alu_result = 32'b0;
        endcase
    end

    assign zero = (alu_result == 32'b0);
endmodule

