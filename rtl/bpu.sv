module bpu(
    input logic clk, rst_n, 

    //fetch
    input logic [31:0] pc, 
    output logic predict_taken, 
    output logic [31:0] predict_target,// from btb 

    //execute - update 
    input logic update_en, //check for branch insturction only
    input logic [31:0] update_pc, //pc of exe instr; how to hash back in 
    input logic actual_taken, // was the branch taken 
    input logic [31:0] actual_target
); 
    localparam ENTRIES = 1024;
    
    //2 bit counter table 
    logic [1:0] counter [0:ENTRIES-1]; 

    //BTB
    logic btb_valid [0:ENTRIES-1]; //is this slot populated --> default predicition =0
    logic [19:0] btb_tag [0:ENTRIES-1]; 
    logic [31:0] btb_target [0:ENTRIES-1]; 

    // index into tables
    logic [9:0] fetch_idx; 
    logic [9:0] update_idx; 

    assign fetch_idx = pc[11:2]; //lower 2 bits always 0 
    assign update_idx = update_pc[11:2]; 

    //Fetch Combinataional Read 
    always_comb begin 
        predict_taken = 1'b0; 
        predict_target = 32'b0; 
        if(btb_valid[fetch_idx] && btb_tag[fetch_idx]==pc[31:12]) begin //is BTB entry valid & does tag match btb_tag
            if(counter[fetch_idx][1])begin
                predict_taken  = 1'b1;
                predict_target = btb_target[fetch_idx];
            end
        end 
    end

    //write 
    always_ff @(posedge clk) begin 
        if(!rst_n) begin 
            integer i; 
            for(i=0; i<ENTRIES; i++)begin 
                counter[i]  = 2'b01;
                btb_valid[i] = 1'b0;
                btb_tag[i]  = 20'b0;
                btb_target[i] = 32'b0;
            end
        end else if (update_en) begin //if branch 
            //update counter
            if(actual_taken)begin 
                if(counter[update_idx]!=2'b11)begin 
                    counter[update_idx] <= counter[update_idx]+1; 
                end
            end else begin 
                if(counter[update_idx]!=2'b00) begin 
                    counter[update_idx] <= counter[update_idx]-1; 
                end
            end

            // update BTB
            btb_valid[update_idx]  <= 1'b1;
            btb_tag[update_idx]    <= update_pc[31:12];
            btb_target[update_idx] <= actual_target;
        end
    end
endmodule