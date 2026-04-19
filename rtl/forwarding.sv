module forwarding (
    input  logic [4:0] id_ex_rs1, id_ex_rs2,
    input  logic [4:0] ex_mem_rd,
    input  logic ex_mem_reg_write,
    input  logic [4:0] mem_wb_rd,
    input  logic mem_wb_reg_write,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);
    always_comb begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX/MEM forward (higher priority)
        if (ex_mem_reg_write && ex_mem_rd != 5'b0) begin
            if (ex_mem_rd == id_ex_rs1) forwardA = 2'b10;
            if (ex_mem_rd == id_ex_rs2) forwardB = 2'b10;
        end

        // MEM/WB forward (lower priority, only if EX/MEM didn't match)
        if (mem_wb_reg_write && mem_wb_rd != 5'b0) begin
            if (mem_wb_rd == id_ex_rs1 && forwardA == 2'b00) forwardA = 2'b01;
            if (mem_wb_rd == id_ex_rs2 && forwardB == 2'b00) forwardB = 2'b01;
        end
    end
endmodule