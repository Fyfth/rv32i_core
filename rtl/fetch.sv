module fetch(
    input logic clk,rst_n,
    input logic stall, 
    input logic predict_taken, //from bpu
    input logic [31:0] predict_target, //fror bpu
    input  logic mispredict, //from execute, actual result
    input  logic [31:0] mispredict_target, //from execute actual address 
    output logic[31:0] pc, instr
); 
    always_ff @(posedge clk) begin
        if (!rst_n) //hard reset
            pc <= 32'b0;
        else if (mispredict) //execute real branch taken
            pc <= mispredict_target; //execute real branch address
        else if(predict_taken)// predict branch_taken 
            pc <= predict_target; 
        else if (!stall)
            pc <= pc + 32'd4;
        // if stall and no branch: hold pc
    end

    imem imem_inst(.pc(pc),.instr(instr)); 
    
endmodule


//you take predict when there is 1st no mispredict 
//you take naive when there is no branch prediction i.e. its not in the btb table
//you stall when stall 

    