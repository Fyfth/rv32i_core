module tb_core;
    logic clk, rst_n;

    core dut(.clk(clk), .rst_n(rst_n));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("obj_dir/tb_core.vcd");
        $dumpvars(0, tb_core);

        // load program
        $readmemh("../tb/program.hex", dut.fetch_unit.imem_inst.mem);

        // reset
        clk = 0; rst_n = 0;
        @(posedge clk);
        @(posedge clk);
        #3; rst_n = 1;

        // run enough cycles for all instructions to complete
        // 5 instructions + 4 pipeline stages + some extra
        repeat(190) @(posedge clk);

        $display("x1 = %0d (expect 20)",  dut.regfile_unit.regs[1]);
        $display("x2 = %0d (expect 20)",  dut.regfile_unit.regs[2]);
        $display("x3 = %0d (expect 119)",  dut.regfile_unit.regs[3]);
        $display("x4 = %0d (expect 0)", dut.regfile_unit.regs[4]);
        
        $finish;
    end
    initial begin
        $display("time  | pc       | if_id_instr| id_ex_rd | alu_result | wb_data");
        forever begin
            @(posedge clk);
            $display("%4t  | %h | %h   | %0d        | %0d         | %0d",
                $time,
                dut.pc,
                dut.if_id_instr,
                dut.id_ex_rd,
                dut.alu_result,
                dut.wb_data);
            $display("%4t | pc=%h | if_id=%h | stall=%b | id_ex_mem_read=%b | id_ex_rd=%0d | forwardA=%b | forwardB=%b",
                $time,
                dut.pc,
                dut.if_id_instr,
                dut.stall,
                dut.id_ex_mem_read,
                dut.id_ex_rd,
                dut.forwardA,
                dut.forwardB);
            $display("%4t | pc=%h | imem_out=%h | if_id=%h",
                $time,
                dut.pc,
                dut.fetch_unit.instr,
                dut.if_id_instr);
            $display("%4t | ex_mem_mem_write=%b | ex_mem_rd2=%0d | ex_mem_alu_result=%0d",
                    $time,
                    dut.ex_mem_mem_write,
                    dut.ex_mem_rd2,
    dut.ex_mem_alu_result);
            $display("%4t | branch_taken=%b | branch_target=%h | id_ex_branch=%b",
                $time,
                dut.branch_taken,
                dut.branch_target,
                dut.id_ex_branch);
            $display("%4t | predict_taken=%b | predict_target=%h",
                $time,
                dut.predict_taken,
                dut.predict_target);
        end
    end
    initial begin
        #1; // wait for readmemh
        $display("imem[0]=%h", dut.fetch_unit.imem_inst.mem[0]);
        $display("imem[1]=%h", dut.fetch_unit.imem_inst.mem[1]);
        $display("imem[2]=%h", dut.fetch_unit.imem_inst.mem[2]);
        $display("imem[3]=%h", dut.fetch_unit.imem_inst.mem[3]);
        $display("imem[4]=%h", dut.fetch_unit.imem_inst.mem[4]);
    end
endmodule