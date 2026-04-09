module tb_decode; 
    logic [31:0] instr; 
    logic [4:0] rs1, rs2, rd; 
    logic [6:0] opcode; 
    logic [2:0] funct3; 
    logic [6:0] funct7; 
    logic [31:0] imm; 
    logic reg_write;  
    logic [1:0] alu_op; 

    decode dut(.*); 

    //no clk needed 

    initial begin
        $dumpfile("obj_dir/tb_decode.vcd");
        $dumpvars(0, tb_decode);

        // test ADD x1, x2, x3
        instr = 32'h003100b3;
        #10;
        $display("ADD: rs1=%0d rs2=%0d rd=%0d alu_op=%b reg_write=%b",
                  rs1, rs2, rd, alu_op, reg_write);
        assert(rs1==2 && rs2==3 && rd==1 && alu_op==2'b10 && reg_write==1)
            else $error("ADD FAILED");

        // test ADDI x4, x5, 10
        instr = 32'h00A28213;
        #10;
        $display("ADDI: rs1=%0d rd=%0d imm=%0d alu_op=%b",
                  rs1, rd, $signed(imm), alu_op);
        assert(rs1==5 && rd==4 && imm==32'd10 && alu_op==2'b10)
            else $error("ADDI FAILED");

        // test LW x1, 0(x2)
        instr = 32'h00012083;
        #10;
        $display("LW: rs1=%0d rd=%0d imm=%0d alu_op=%b",
                  rs1, rd, $signed(imm), alu_op);
        assert(rs1==2 && rd==1 && imm==32'd0 && alu_op==2'b00)
            else $error("LW FAILED");

        // SW x2, 8(x1) — S-type
        instr = 32'h0020A423;
        #10;
        $display("SW: rs1=%0d rs2=%0d imm=%0d alu_op=%b reg_write=%b",
                rs1, rs2, $signed(imm), alu_op, reg_write);
        assert(rs1==1 && rs2==2 && imm==32'd8 && alu_op==2'b00 && reg_write==0)
            else $error("SW FAILED");

        // BEQ x1, x2, 8 — B-type
        instr = 32'h00208463;
        #10;
        $display("BEQ: rs1=%0d rs2=%0d imm=%0d alu_op=%b reg_write=%b",
                rs1, rs2, $signed(imm), alu_op, reg_write);
        assert(rs1==1 && rs2==2 && imm==32'd8 && alu_op==2'b01 && reg_write==0)
            else $error("BEQ FAILED");

        // LUI x1, 0x12345 — U-type
        instr = 32'h123450B7;
        #10;
        $display("LUI: rd=%0d imm=%0h alu_op=%b reg_write=%b",
                rd, imm, alu_op, reg_write);
        assert(rd==1 && imm==32'h12345000 && alu_op==2'b00 && reg_write==1)
            else $error("LUI FAILED");

        // JAL x1, 0 — J-type
        instr = 32'h000000EF;
        #10;
        $display("JAL: rd=%0d imm=%0d alu_op=%b reg_write=%b",
                rd, $signed(imm), alu_op, reg_write);
        assert(rd==1 && imm==32'd0 && alu_op==2'b00 && reg_write==1)
            else $error("JAL FAILED");

        $finish;
    end
endmodule