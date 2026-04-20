module bpu(
    input  logic clk, rst_n,
    input  logic [31:0] pc,
    output logic predict_taken,
    output logic [31:0] predict_target,
    input  logic update_en,
    input  logic [31:0] update_pc,
    input  logic actual_taken,
    input  logic [31:0] actual_target
);
    localparam ENTRIES = 1024;
 
    //T0 table: base predictor (local 2-bit, no tag)
    logic [1:0] t0_counter [0:ENTRIES-1];
 
    //BTB 
    logic btb_valid [0:ENTRIES-1];
    //logic [3:0] btb_tag [0:ENTRIES-1];  // IDN't WORK!!! was [19:0] ; CHANGED DUE TO ALISING PROBLEM; PROGRAM TOO SMALL
    logic [19:0] btb_tag [0:ENTRIES-1];
    logic [31:0] btb_target [0:ENTRIES-1];
 
    //T1 table: 8-bit history, 512 entries
    logic [1:0] t1_counter [0:511];
    logic [7:0] t1_tag [0:511];
    logic t1_valid[0:511];
 
    //T2 table: 16-bit history folded to 8-bit index, 256 entries 
    logic [1:0] t2_counter [0:255];
    logic [7:0] t2_tag [0:255];
    logic t2_valid [0:255];
 
    //GHR 16 bits 
    // logic [15:0] GHR;

    //GHR 8 bits 
    logic [7:0] GHR;  // shrink from 16 to 8 bits
 
    //fetch indices
    logic [9:0] fetch_idx;
    logic [8:0] t1_idx;
    logic [7:0] t1_tag_fetch;
    logic t1_hit;
    logic [7:0] t2_idx;
    logic [7:0] t2_tag_fetch;
    logic t2_hit;
 
    assign fetch_idx = pc[11:2];
    //8 bit history T1
    // assign t1_idx = pc[8:0] ^ {1'b0, GHR[7:0]};
    // assign t1_tag_fetch = pc[16:9] ^ GHR[15:8];

    //4 bit 
    // T1: 4-bit history
    assign t1_idx       = pc[8:0] ^ {5'b0, GHR[3:0]};
    assign t1_tag_fetch = pc[16:9] ^ {4'b0, GHR[7:4]};
    assign t1_hit = t1_valid[t1_idx] && (t1_tag[t1_idx] == t1_tag_fetch);

    //16 bit T2 history 
    // assign t2_idx = pc[7:0] ^ GHR[15:8] ^ GHR[7:0];
    // assign t2_tag_fetch = pc[23:16] ^ GHR[7:0];

    // T2: 8-bit history  
    assign t2_idx       = pc[7:0] ^ {4'b0, GHR[7:4]} ^ {4'b0, GHR[3:0]};
    assign t2_tag_fetch = pc[23:16] ^ {4'b0, GHR[3:0]};
    assign t2_hit = t2_valid[t2_idx] && (t2_tag[t2_idx] == t2_tag_fetch);
 
    //update indices
    logic [9:0] update_idx;
    logic [8:0] t1_update_idx;
    logic [7:0] t1_update_tag;
    logic [7:0] t2_update_idx;
    logic [7:0] t2_update_tag;


    //16 bit GHR
    // assign update_idx = update_pc[11:2];
    // assign t1_update_idx = update_pc[8:0]  ^ {1'b0, GHR[7:0]};
    // assign t1_update_tag = update_pc[16:9] ^ GHR[15:8];
    // assign t2_update_idx = update_pc[7:0]  ^ GHR[15:8] ^ GHR[7:0];
    // assign t2_update_tag = update_pc[23:16] ^ GHR[7:0];

    //8 bit GHR
    assign update_idx    = update_pc[11:2];
    assign t1_update_idx = update_pc[8:0]  ^ {5'b0, GHR[3:0]};
    assign t1_update_tag = update_pc[16:9] ^ {4'b0, GHR[7:4]};
    assign t2_update_idx = update_pc[7:0]  ^ {4'b0, GHR[7:4]} ^ {4'b0, GHR[3:0]};
    assign t2_update_tag = update_pc[23:16] ^ {4'b0, GHR[3:0]};
 
    //combinational READ --> inference :read btb table & counter 2nd bit
    always_comb begin
        predict_taken = 1'b0;
        predict_target = 32'b0;
        if (btb_valid[fetch_idx] && btb_tag[fetch_idx] == pc[31:12]) begin //31:12 upper bits
            predict_target = btb_target[fetch_idx]; //independnet of predict -> muxed out in fetch 
            if (t2_hit)                             //priority encoder --> Longest history wins 
                predict_taken = t2_counter[t2_idx][1];
            else if (t1_hit)
                predict_taken = t1_counter[t1_idx][1];
            else
                predict_taken = t0_counter[fetch_idx][1];
        end
    end
 
    // Training & back prop update (lol)
    always_ff @(posedge clk) begin
        if (!rst_n) begin //reset 
            integer i;
            for (i = 0; i < ENTRIES; i++) begin
                t0_counter[i] = 2'b01;
                btb_valid[i]  = 1'b0;
                btb_tag[i] = 20'b0;
                btb_target[i] = 32'b0;
            end
            for (i = 0; i < 512; i++) begin
                t1_counter[i] = 2'b01;
                t1_valid[i]   = 1'b0;
                t1_tag[i]     = 8'b0;
            end
            for (i = 0; i < 256; i++) begin
                t2_counter[i] = 2'b01;
                t2_valid[i]   = 1'b0;
                t2_tag[i]     = 8'b0;
            end

            //16 bit
            // GHR <= 16'b0; //important

            //8bit 
            GHR <= 8'b0;
        end else begin
            // GHR shift            GHR MUST ONLY SHIFT ON BRANCH INSTRUCTIONS!! 
            if (update_en)
                //16 bit 
                // GHR <= {GHR[14:0], actual_taken};
                // 8 bit
                GHR <= {GHR[6:0], actual_taken};  // 8-bit shift
 
            if (update_en) begin
                // T0 update (always)
                if (actual_taken) begin
                    if (t0_counter[update_idx] != 2'b11)
                        t0_counter[update_idx] <= t0_counter[update_idx] + 1;
                end else begin
                    if (t0_counter[update_idx] != 2'b00)
                        t0_counter[update_idx] <= t0_counter[update_idx] - 1;
                end
 
                //BTB update
                btb_valid[update_idx] <= 1'b1;
                btb_tag[update_idx] <= update_pc[31:12];
                btb_target[update_idx] <= actual_target;
 
                //T1 update
                if (t1_valid[t1_update_idx] &&
                    t1_tag[t1_update_idx] == t1_update_tag) begin
                    if (actual_taken) begin
                        if (t1_counter[t1_update_idx] != 2'b11)
                            t1_counter[t1_update_idx] <= t1_counter[t1_update_idx] + 1;
                    end else begin
                        if (t1_counter[t1_update_idx] != 2'b00)
                            t1_counter[t1_update_idx] <= t1_counter[t1_update_idx] - 1;
                    end
                end else begin
                    t1_valid[t1_update_idx]   <= 1'b1;
                    t1_tag[t1_update_idx]     <= t1_update_tag;
                    t1_counter[t1_update_idx] <= actual_taken ? 2'b10 : 2'b01;
                end
 
                //T2 update
                if (t2_valid[t2_update_idx] &&
                    t2_tag[t2_update_idx] == t2_update_tag) begin
                    if (actual_taken) begin
                        if (t2_counter[t2_update_idx] != 2'b11)
                            t2_counter[t2_update_idx] <= t2_counter[t2_update_idx] + 1;
                    end else begin
                        if (t2_counter[t2_update_idx] != 2'b00)
                            t2_counter[t2_update_idx] <= t2_counter[t2_update_idx] - 1;
                    end
                end else begin
                    t2_valid[t2_update_idx]   <= 1'b1;
                    t2_tag[t2_update_idx]     <= t2_update_tag;
                    t2_counter[t2_update_idx] <= actual_taken ? 2'b10 : 2'b01;
                end
            end
        end
    end
 
endmodule