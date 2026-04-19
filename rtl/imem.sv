module imem(
    input logic[31:0] pc,
    output logic[31:0] instr
); 
    logic [31:0] mem[2047:0]; //1024 insturction, 32 bits wide

    assign instr = mem[pc[12:2]]; //2^11 = 2048; lsb 2 bits always 0 
endmodule