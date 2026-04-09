module tb_fetch; 
    logic clk,rst_n; 
    logic[31:0] pc, instr; 
    
    
    fetch fetch_inst(.clk(clk), .rst_n(rst_n), .pc(pc), .instr(instr)); 
    always #5 clk = ~clk; 

    initial begin
        $dumpfile("obj_dir/tb_fetch.vcd"); //vcd = variable change dump 
        $dumpvars(0, tb_fetch); //0 means record everything, tb_regfile is top level 
        $readmemh("../tb/program.hex", fetch_inst.imem_inst.mem);

        //reset
        clk=0; rst_n=0; 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        #3 rst_n=1; //need #3 or else on first iteration it takes else branch and +4 
  

        repeat(6) begin 
            @(posedge clk); 
            $display("pc=%0d instr=%h", pc, instr);
        end
        $finish;
    end
endmodule









