module fetch(
    input logic clk,rst_n,
    output logic[31:0] pc, instr
); 
    always_ff @(posedge clk) begin 
        if(!rst_n) begin 
            pc <=32'b0; 
        end else begin 
            pc<=pc+32'd4; 
        end
    end

    imem imem_inst(.pc(pc),.instr(instr)); 
    
endmodule

    