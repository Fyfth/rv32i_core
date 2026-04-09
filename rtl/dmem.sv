module dmem(
    input logic clk, we,
    input logic[31:0] addr, wd,
    output logic[31:0] rd 
); 
    logic[31:0] mem[2047:0]; 
    //combinational read 
    assign rd = (we==0)? mem[addr[12:2]]:rd; 

    //sync write 
    always_ff @(posedge clk) begin 
        if(we) begin
            mem[addr[12:2]] <=wd; 
        end
    end 

endmodule