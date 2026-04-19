module core(
    input logic clk, 
    input logic rst_n
); 
    logic stall; 
    //IF stage 
    logic [31:0] pc, instr; 
    logic  branch_taken; 
    logic [31:0] branch_target; 

    //branch prediction unit 
    logic predict_taken; 
    logic [31:0] predict_target; 
    logic if_id_predicted_taken;
    logic [31:0]if_id_predicted_target;
    logic mispredict; 
    logic [31:0] mispredict_target; 

   bpu bpu_unit(
    .clk(clk), .rst_n(rst_n), .pc(pc), .predict_taken(predict_taken),.predict_target(predict_target),
    .update_en(id_ex_branch != 2'b00), .update_pc(id_ex_pc),.actual_taken(branch_taken), .actual_target(branch_target)   
    ); 

    fetch fetch_unit(.clk(clk),.rst_n(rst_n),.pc(pc), .stall(stall),.instr(instr), .predict_taken(predict_taken), 
    .predict_target(predict_target),.mispredict(mispredict),.mispredict_target(mispredict_target)); 
    

    //IF --> Decode Register 
    logic [31:0] if_id_instr, if_id_pc;
    always_ff @(posedge clk) begin 
        if (!rst_n||mispredict) begin
            if_id_instr<=32'b0; 
            if_id_pc <=32'b0;
            if_id_predicted_taken <= 1'b0; 
            if_id_predicted_target <=32'b0; 
        end
        else if(!stall) begin 
            if_id_instr <= instr; 
            if_id_pc <= pc; 
            if_id_predicted_taken <= predict_taken;
            if_id_predicted_target <= predict_target; 
        end
    end


    //Decode Stage
    logic [4:0] rs1, rs2, rd; 
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm, rd1, rd2, wd; 
    logic reg_write; 
    logic [1:0] alu_op; 
    logic alu_src; 
    logic mem_read;   // loads
    logic mem_write;    // stores
    logic mem_to_reg; 
    logic [1:0] branch; 



    //Decode
    decode decode_unit(.instr(if_id_instr),.rs1(rs1), .rs2(rs2), .rd(rd),.opcode(opcode),.funct3(funct3),
    .funct7(funct7),.imm(imm),.reg_write(reg_write), .alu_op(alu_op),.alu_src(alu_src),
    .mem_read(mem_read), .mem_write(mem_write),.mem_to_reg(mem_to_reg), .branch(branch));

    logic [4:0] id_ex_rd, id_ex_rs1, id_ex_rs2;
    logic [31:0] id_ex_rd1, id_ex_rd2, id_ex_imm, id_ex_pc;
    logic [2:0] id_ex_funct3;
    logic [6:0] id_ex_funct7;
    logic [1:0] id_ex_alu_op;
    logic id_ex_alu_src, id_ex_reg_write;
    logic id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    logic [31:0] wb_data; // writeback mux output
    logic [4:0]  mem_wb_rd; // destination reg from MEM/WB
    logic mem_wb_reg_write;
    logic [1:0] id_ex_branch; 
    logic id_ex_predicted_taken;
    logic [31:0]id_ex_predicted_target;

    regfile regfile_unit (.clk(clk),.we(mem_wb_reg_write),.rs1(rs1),.rs2(rs2),.rd(mem_wb_rd),.wd(wb_data),.rd1(rd1),.rd2(rd2));

    //id_ex register 
    always_ff @(posedge clk) begin
        if (!rst_n || stall||mispredict) begin//NOP on STALL --> MUST FLUSH i.e. exe is combinational
            id_ex_rd <= 5'b0;
            id_ex_rs1 <= 5'b0;
            id_ex_rs2 <= 5'b0;
            id_ex_rd1 <= 32'b0;
            id_ex_rd2 <= 32'b0;
            id_ex_imm <= 32'b0;
            id_ex_pc <= 32'b0;
            id_ex_funct3 <= 3'b0;
            id_ex_funct7 <= 7'b0;
            id_ex_alu_op <= 2'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_branch <= 2'b0; 
            id_ex_predicted_taken <=1'b0; 
            id_ex_predicted_target <=32'b0; 
        end else begin
            id_ex_rd <= rd;
            id_ex_rs1 <= rs1;
            id_ex_rs2 <= rs2;
            id_ex_rd1 <= rd1;
            id_ex_rd2 <= rd2;
            id_ex_imm <= imm;
            id_ex_pc <= if_id_pc;
            id_ex_funct3 <= funct3;
            id_ex_funct7 <= funct7;
            id_ex_alu_op <= alu_op;
            id_ex_alu_src <= alu_src;
            id_ex_reg_write <= reg_write;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_mem_to_reg <= mem_to_reg;
            id_ex_branch <= branch; 
            id_ex_predicted_taken <= if_id_predicted_taken; 
            id_ex_predicted_target <= if_id_predicted_target; 
        end
    end
    logic[1:0] forwardA, forwardB;

    //stall
    hazard stall_unit(.if_id_instr(if_id_instr),.id_ex_rd(id_ex_rd),.id_ex_mem_read(id_ex_mem_read), 
        .stall(stall));

    //forwarding unit --> i.e. 3 inputs mux to 1 output in to .a & .b --> 2 muxes 
    forwarding forward_unit(.id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),.ex_mem_rd(ex_mem_rd),
                            .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_rd(mem_wb_rd), 
                            .mem_wb_reg_write(mem_wb_reg_write),
                            .forwardA(forwardA), .forwardB(forwardB)
    );
    
    //execute 

    logic[31:0] alu_result; 
    logic[31:0] rd2_fwd_wire; 
    logic zero; 
    execute execute_unit(.rd1(id_ex_rd1),.rd2(id_ex_rd2),.imm(id_ex_imm),.funct3(id_ex_funct3),
    .funct7(id_ex_funct7),.alu_op(id_ex_alu_op), .alu_src(id_ex_alu_src),.alu_result(alu_result),
    .zero(zero), .forwardA(forwardA), .forwardB(forwardB), .ex_mem_result(ex_mem_alu_result), .mem_wb_result(wb_data),
    .rd2_forwarded(rd2_fwd_wire));

    //branch resolution: 

    always_comb begin
        branch_taken  = 1'b0;
        branch_target = 32'b0;
        if(id_ex_branch == 2'b10) begin  //JAL 
            branch_taken = 1'b1;
            branch_target = id_ex_pc + id_ex_imm;
        end
        else if(id_ex_branch ==2'b11) begin //JALR
            branch_taken =1'b1; 
            branch_target = alu_result; 
        end
        else if(id_ex_branch ==2'b01) begin 
            branch_target = id_ex_pc + id_ex_imm;
            case(id_ex_funct3) 
                3'b000: branch_taken = zero;           // BEQ
                3'b001: branch_taken = !zero;          // BNE
                3'b100: branch_taken = alu_result[31]; // BLT
                3'b101: branch_taken = !alu_result[31];// BGE
                3'b110: branch_taken = !zero;          // BLTU (simplified)
                3'b111: branch_taken = zero;           // BGEU (simplified)
                default: branch_taken = 1'b0;
            endcase
        end
    end

    assign mispredict = (id_ex_branch != 2'b00) && (branch_taken != id_ex_predicted_taken);
    assign mispredict_target = branch_taken ? branch_target : (id_ex_pc + 32'd4);
    //if predict doens't match, actual 


    // EX/MEM pipeline register
    logic [4:0]  ex_mem_rd;
    logic [31:0] ex_mem_alu_result, ex_mem_rd2;
    logic ex_mem_zero;
    logic ex_mem_reg_write, ex_mem_mem_read;
    logic ex_mem_mem_write, ex_mem_mem_to_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ex_mem_rd <= 5'b0;
            ex_mem_alu_result <= 32'b0;
            ex_mem_rd2 <= 32'b0;
            ex_mem_zero <= 1'b0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
        end else begin
            ex_mem_rd <= id_ex_rd;
            ex_mem_alu_result <= alu_result;
            ex_mem_rd2 <= rd2_fwd_wire;
            ex_mem_zero <= zero;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
        end
    end

    // MEM
    logic [31:0] mem_alu_result, mem_read_data;

    mem mem_unit (
        .clk(clk),
        .alu_result_in(ex_mem_alu_result),
        .rd2(ex_mem_rd2),
        .mem_write(ex_mem_mem_write),
        .mem_read(ex_mem_mem_read),
        .alu_result(mem_alu_result),
        .read_data(mem_read_data)
    );

    // MEM/WB Register
    logic [31:0] mem_wb_alu_result, mem_wb_read_data;
    logic mem_wb_mem_to_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mem_wb_rd <= 5'b0;
            mem_wb_alu_result <= 32'b0;
            mem_wb_read_data <= 32'b0;
            mem_wb_reg_write <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;
        end else begin
            mem_wb_rd <= ex_mem_rd;
            mem_wb_alu_result <= mem_alu_result;
            mem_wb_read_data <= mem_read_data;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        end
    end

    // WB
    assign wb_data = mem_wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result;

endmodule        










    