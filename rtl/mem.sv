module mem(//3 cases, pass value to write back, load (read data), write(store data)
    input logic clk, 
    input logic[31:0] alu_result_in,  //register result or load/store address; 
    input logic[31:0] rd2, //store data
    input logic mem_write, mem_read,  
    output logic[31:0] alu_result, 
    output logic[31:0] read_data 
); 

    assign alu_result = alu_result_in; 
    dmem dmem_inst(.clk(clk), .we(mem_write),.addr(alu_result_in), .wd(rd2),.rd(read_data)); 

endmodule
