`timescale 1ns/1ps

module branch_jump_logic (
    input  logic [31:0] pc,
    input  logic [31:0] rs1_value,
    input  logic [31:0] rs2_value,

    input  logic [31:0] branch_immediate,
    input  logic [31:0] jump_immediate,

    input  logic [2:0] funct3,

    input  logic branch,
    input  logic jump,
    input  logic jalr,

    output logic [31:0] next_pc,
    output logic        branch_taken
);

    // Branch types
    localparam logic [2:0] BEQ = 3'b000;
    localparam logic [2:0] BNE = 3'b001;

    always_comb begin

        // Default:
        // Move to next sequential instruction
        next_pc = pc + 32'd4;
        branch_taken = 1'b0;

        // ==========================================
        // BRANCH INSTRUCTIONS
        // ==========================================

        if (branch) begin

            case (funct3)

                // BEQ
                BEQ: begin
                    if (rs1_value == rs2_value) begin
                        next_pc = pc + branch_immediate;
                        branch_taken = 1'b1;
                    end
                end

                // BNE
                BNE: begin
                    if (rs1_value != rs2_value) begin
                        next_pc = pc + branch_immediate;
                        branch_taken = 1'b1;
                    end
                end

                default: begin
                    next_pc = pc + 32'd4;
                    branch_taken = 1'b0;
                end

            endcase

        end

        // ==========================================
        // JUMP INSTRUCTIONS
        // ==========================================

        if (jump) begin

            // JALR:
            // target = rs1 + immediate
            if (jalr) begin
                next_pc = (rs1_value + jump_immediate)
                          & 32'hFFFFFFFE;
            end

            // JAL:
            // target = PC + immediate
            else begin
                next_pc = pc + jump_immediate;
            end

        end

    end

endmodule
