module decode (
    input  logic [31:0] instr,
    output logic [4:0] rs1, rs2, rd,
    output logic [6:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm,
    output logic reg_write, 
    output logic [1:0] alu_op
);
    always_comb begin
    // // defaults
    // rs1 = 5'b0; rs2 = 5'b0; rd = 5'b0;
    // funct3 = 3'b0; funct7 = 7'b0;
    // imm = 32'b0; reg_write = 0;
    // alu_op = 2'b10; 
    // opcode = instr[6:0];//always true

        case (instr[6:0])
            7'b0110011: begin // R type
                rs1 = instr[19:15];
                rs2 = instr[24:20];
                rd  = instr[11:7];
                funct3 = instr[14:12];
                funct7 = instr[31:25];
                reg_write = 1;
                imm = 32'b0;  // R type has no immediate
                alu_op = 2'b10; 
            end

            7'b0010011: begin  // I type ALU
                rs1 = instr[19:15];
                rs2 = 5'b0;
                rd = instr[11:7];
                funct3 = instr[14:12];
                funct7 = 7'b0;
                reg_write = 1;
                imm = {{20{instr[31]}}, instr[31:20]}; //sign extended top 20
                alu_op = 2'b10; 
            end

            7'b0000011: begin //I type load 
                rs1 = instr[19:15];
                rs2 = 5'b0; 
                rd = instr[11:7]; 
                funct3 = instr[14:12]; 
                funct7 = 7'b0; 
                reg_write =1; 
                imm = {{20{instr[31]}}, instr[31:20]};
                alu_op = 2'b00; 
            end

            7'b0100011: begin //S type load 
                rs1 = instr[19:15]; 
                rs2 = instr[24:20]; 
                rd = 5'b0; 
                funct3 = instr[14:12]; 
                funct7 = 7'b0; 
                reg_write = 0; 
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_op = 2'b00; 
            end

            7'b1100011: begin //B type
                rs1= instr[19:15]; 
                rs2 = instr[24:20]; 
                rd = 5'b0; 
                funct3 = instr[14:12]; 
                funct7 = 7'b0; 
                reg_write = 0; 
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
                alu_op = 2'b01; 
            end

            7'b0110111: begin //U type LUI 
                rs1= 5'b0; 
                rs2 = 5'b0;
                rd = instr[11:7]; 
                funct3 = 3'b0; 
                funct7 = 7'b0; 
                reg_write = 1; 
                imm = {instr[31:12], 12'b0 };
                alu_op = 2'b00; 
            end

            7'b0010111: begin //U type auipc
                rs1= 5'b0; 
                rs2 = 5'b0;
                rd = instr[11:7];
                funct3 = 3'b0; 
                funct7 = 7'b0; 
                reg_write = 1; 
                imm = {instr[31:12], 12'b0 };
                alu_op = 2'b00; 
            end

            7'b1101111: begin //J Type JAL 
                rs1 = 5'b0;
                rs2 = 5'b0;
                rd  = instr[11:7];
                funct3 = 3'b0;
                funct7 = 7'b0;
                reg_write = 1;
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                alu_op = 2'b00;
            end

            7'b1100111 : begin //J Type jalr
                rs1 = instr[19:15];
                rs2 = 5'b0;
                rd  = instr[11:7];
                funct3 = instr[14:12];
                funct7 = 7'b0;
                reg_write = 1;
                imm = {{20{instr[31]}}, instr[31:20]};
                alu_op = 2'b00;
            end

            default: begin
                rs1 = 5'b0; rs2 = 5'b0; rd = 5'b0;
                funct3 = 3'b0; funct7 = 7'b0;
                imm = 32'b0; reg_write = 0;
                alu_op = 2'b00;
            end
        endcase
    end
endmodule


