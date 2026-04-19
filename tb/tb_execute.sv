module tb_execute; 
    import rv32i_pkg::*;
    logic[31:0] rd1, rd2; 
    logic[31:0] imm; 
    logic[2:0] funct3; 
    logic[6:0] funct7; 
    logic[1:0] alu_op; 
    logic alu_src; 
    logic[31:0] alu_result; 
    logic zero; 

    execute dut(.*); 

    initial begin
        $dumpfile("obj_dir/tb_execute.vcd");
        $dumpvars(0, tb_execute);

        // ADD rd1+rd2
        rd1=32'd10; rd2=32'd5; imm=32'd0;
        funct3=3'b000; funct7=7'b0000000;
        alu_op=2'b10; alu_src=0;
        #10;
        $display("ADD: %0d+%0d=%0d (expect 15)", rd1, rd2, alu_result);
        assert(alu_result==32'd15) else $error("ADD FAILED");

        // ADDI rd1+imm
        rd1=32'd10; imm=32'd5;
        alu_op=2'b10; alu_src=1;
        #10;
        $display("ADDI: %0d+%0d=%0d (expect 15)", rd1, imm, alu_result);
        assert(alu_result==32'd15) else $error("ADDI FAILED");

        // SUB rd1-rd2
        rd1=32'd10; rd2=32'd3; alu_src=0;
        funct7=7'b0100000;
        #10;
        $display("SUB: %0d-%0d=%0d (expect 7)", rd1, rd2, alu_result);
        assert(alu_result==32'd7) else $error("SUB FAILED");

        // AND
        rd1=32'hFF; rd2=32'h0F;
        funct3=3'b111; funct7=7'b0000000;
        #10;
        $display("AND: %0h&%0h=%0h (expect 0f)", rd1, rd2, alu_result);
        assert(alu_result==32'h0F) else $error("AND FAILED");

        // zero flag
        rd1=32'd5; rd2=32'd5;
        funct3=3'b000; funct7=7'b0100000; // SUB
        #10;
        $display("ZERO: %0d-%0d=0? zero=%b (expect 1)", rd1, rd2, zero);
        assert(zero==1) else $error("ZERO FLAG FAILED");

        $finish;
    end
endmodule