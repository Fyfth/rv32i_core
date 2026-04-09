module tb_regfile;
    //declare variables 
    logic clk, we;
    logic[4:0] rs1,rs2,rd;
    logic[31:0] wd, rd1, rd2; 

    regfile dut (.*); //.* auto connect by name 

    always #5 clk = ~clk; 

    initial begin
        $dumpfile("obj_dir/tb_regfile.vcd"); //vcd = variable change dump 
        $dumpvars(0, tb_regfile); //0 means record everything, tb_regfile is top level 

        clk=0; rs1=0; rs2=0; rd=0; wd=0;  

        //write 42 to reg1
        @(posedge clk); we=1; rd=5'd1; wd = 32'd42;
        //write 99 to reg2
        @(posedge clk); we=1; rd=5'd2; wd = 32'd99;

        //read r1 and r2
        @(posedge clk); we=0; rs1 = 5'd1; rs2 = 5'd2;

        @(posedge clk);
        $display("x1 = %0d (expect 42)", rd1);
        $display("x2 = %0d (expect 99)", rd2);

        // Try writing to x0, should stay 0
        @(posedge clk); we=1; rd= 5'd0; wd= 32'hDEADBEEF;
        @(posedge clk); we=0; rs1 = 5'd0; 

        @(posedge clk); 
        $display("x1 = %0d (expect 0)", rd1);

        $finish; 
    end
endmodule










