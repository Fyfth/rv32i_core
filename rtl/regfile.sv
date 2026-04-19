module regfile(
    input logic clk, 
    input logic we, 
    input logic[4:0] rs1, rs2, 
    input logic[4:0] rd, 
    input logic[31:0] wd,
    output logic[31:0] rd1, rd2
); 

    //can't write to R0, read from R0 is always 0 
    logic [31:0] regs[31:0]; 
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : (((rs1 == rd) && we) ? wd : regs[rs1]);
    //if write and read happens together, you read output what you wrote 
    //decode, execute, mem, writeback, this is 3 insturction gap forwarding 

    assign rd2 = (rs2 == 5'b0) ? 32'b0 : (((rs2 == rd) && we) ? wd : regs[rs2]);

    //write
    always_ff @(posedge clk) begin 
        if(we && rd!=5'b0)
            regs[rd]<=wd; 
    end
endmodule

