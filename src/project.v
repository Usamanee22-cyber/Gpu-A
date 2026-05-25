module AI_GPU_Mega_Core_16Bit (
    input wire clk,
    input wire rst,
    output reg [15:0] out_data,
    output reg display_valid,
    output reg h_sync,
    output reg v_sync,
    output reg [7:0] pixel_color
);

    reg [15:0] reg_accumulator;
    reg [15:0] reg_vector_x [0:3];
    reg [15:0] reg_vector_y [0:3];
    reg [31:0] mac_matrix_accumulator;
    
    reg [15:0] internal_sram [0:15];
    
    reg [15:0] pipeline_instruction;
    reg [3:0] master_execution_state;
    
    reg [9:0] screen_scan_x;
    reg [9:0] screen_scan_y;

    wire [3:0] inst_opcode;
    wire [3:0] inst_dest_reg;
    wire [7:0] inst_immediate_value;

    assign inst_opcode = pipeline_instruction[15:12];
    assign inst_dest_reg = pipeline_instruction[11:8];
    assign inst_immediate_value = pipeline_instruction[7:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            screen_scan_x <= 10'b00_0000_0000;
            screen_scan_y <= 10'b00_0000_0000;
            h_sync <= 1'b1;
            v_sync <= 1'b1;
            pixel_color <= 8'b0000_0000;
        end else begin
            if (screen_scan_x >= 10'd799) begin
                screen_scan_x <= 10'b00_0000_0000;
                if (screen_scan_y >= 10'd524) begin
                    screen_scan_y <= 10'b00_0000_0000;
                end else begin
                    screen_scan_y <= screen_scan_y + 1'b1;
                end
            end else begin
                screen_scan_x <= screen_scan_x + 1'b1;
            end

            if (screen_scan_x >= 10'd656 && screen_scan_x <= 10'd751) begin
                h_sync <= 1'b0;
            end else begin
                h_sync <= 1'b1;
            end

            if (screen_scan_y >= 10'd490 && screen_scan_y <= 10'd491) begin
                v_sync <= 1'b0;
            end else begin
                v_sync <= 1'b1;
            end

            if (screen_scan_x < 10'd640 && screen_scan_y < 10'd480) begin
                pixel_color <= reg_accumulator[7:0] ^ screen_scan_x[7:0];
            end else begin
                pixel_color <= 8'b0000_0000;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_accumulator <= 16'b0000_0000_0000_0000;
            mac_matrix_accumulator <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
            out_data <= 16'b0000_0000_0000_0000;
            display_valid <= 1'b0;
            master_execution_state <= 4'b0000;
            pipeline_instruction <= 16'b0000_0000_0000_0000;
            
            reg_vector_x[0] <= 16'h0000; reg_vector_x[1] <= 16'h0000;
            reg_vector_x[2] <= 16'h0000; reg_vector_x[3] <= 16'h0000;
            reg_vector_y[0] <= 16'h0000; reg_vector_y[1] <= 16'h0000;
            reg_vector_y[2] <= 16'h0000; reg_vector_y[3] <= 16'h0000;
            
            internal_sram[0]  <= 16'h1005; 
            internal_sram[1]  <= 16'h210A; 
            internal_sram[2]  <= 16'h3202; 
            internal_sram[3]  <= 16'h4303; 
            internal_sram[4]  <= 16'h5000; 
            internal_sram[5]  <= 16'h6000; 
            internal_sram[6]  <= 16'h7000; 
            internal_sram[7]  <= 16'h8001; 
            internal_sram[8]  <= 16'h0000; internal_sram[9]  <= 16'h0000;
            internal_sram[10] <= 16'h0000; internal_sram[11] <= 16'h0000;
            internal_sram[12] <= 16'h0000; internal_sram[13] <= 16'h0000;
            internal_sram[14] <= 16'h0000; internal_sram[15] <= 16'h0000;
        end else begin
            display_valid <= 1'b0;

            case (master_execution_state)
                4'b0000: begin
                    pipeline_instruction <= internal_sram[0];
                    master_execution_state <= 4'b0001;
                end
                4'b0001: begin
                    pipeline_instruction <= internal_sram[1];
                    master_execution_state <= 4'b0010;
                end
                4'b0010: begin
                    pipeline_instruction <= internal_sram[2];
                    master_execution_state <= 4'b0011;
                end
                4'b0011: begin
                    pipeline_instruction <= internal_sram[3];
                    master_execution_state <= 4'b0100;
                end
                4'b0100: begin
                    pipeline_instruction <= internal_sram[4];
                    master_execution_state <= 4'b0101;
                end
                4'b0101: begin
                    pipeline_instruction <= internal_sram[5];
                    master_execution_state <= 4'b0110;
                end
                4'b0110: begin
                    pipeline_instruction <= internal_sram[6];
                    master_execution_state <= 4'b0111;
                end
                4'b0111: begin
                    pipeline_instruction <= internal_sram[7];
                    master_execution_state <= 4'b1000;
                end
                default: begin
                    pipeline_instruction <= 16'h0000;
                end
            endcase

            case (inst_opcode)
                4'b0001: begin
                    reg_accumulator <= {8'b0000_0000, inst_immediate_value};
                end
                
                4'b0010: begin
                    if (inst_dest_reg < 4'd4) begin
                        reg_vector_x[inst_dest_reg] <= {8'b0000_0000, inst_immediate_value};
                    end
                end
                
                4'b0011: begin
                    if (inst_dest_reg < 4'd4) begin
                        reg_vector_y[inst_dest_reg] <= {8'b0000_0000, inst_immediate_value};
                    end
                end
                
                4'b0100: begin
                    reg_accumulator <= reg_accumulator + {8'b0000_0000, inst_immediate_value};
                end
                
                4'b0101: begin
                    mac_matrix_accumulator <= mac_matrix_accumulator + 
                        (reg_vector_x[0] * reg_vector_y[0]) +
                        (reg_vector_x[1] * reg_vector_y[1]) +
                        (reg_vector_x[2] * reg_vector_y[2]) +
                        (reg_vector_x[3] * reg_vector_y[3]);
                end
                
                4'b0110: begin
                    if (reg_accumulator[15] == 1'b1) begin
                        reg_accumulator <= 16'b0000_0000_0000_0000;
                    end else begin
                        reg_accumulator <= reg_accumulator;
                    end
                end
                
                4'b0111: begin
                    reg_accumulator <= reg_accumulator ^ {8'b0000_0000, inst_immediate_value};
                end
                
                4'b1000: begin
                    if (inst_immediate_value == 8'h01) begin
                        out_data <= reg_accumulator;
                    end else if (inst_immediate_value == 8'h02) begin
                        out_data <= mac_matrix_accumulator[15:0];
                    end
                    display_valid <= 1'b1;
                end
                
                default: begin
                    reg_accumulator <= reg_accumulator;
                end
            endcase
        end
    end
endmodule
