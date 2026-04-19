module hazard(
    input  logic[31:0] if_id_instr, 
    input  logic [4:0] id_ex_rd,
    input  logic id_ex_mem_read, //load instruction detect 
    output logic stall
); 
    //i.e. load, read, back to back 
   always_comb begin
        stall = id_ex_mem_read && id_ex_rd != 5'b0 && (id_ex_rd == if_id_instr[19:15]
                ||id_ex_rd == if_id_instr[24:20]);
   end

endmodule