`timescale 1ns/1ps

module write_back_logic (

    input  logic [31:0] alu_result,
    input  logic [31:0] memory_data,
    input  logic [31:0] pc_plus_4,

    input  logic [1:0]  wb_sel,

    output logic [31:0] write_back_data,

    // Optional debug/output copy
    output logic [31:0] pc_plus_4_value

);

    // =========================================================
    // PC + 4 DEBUG / FORWARD OUTPUT
    // =========================================================

    always_comb begin
        pc_plus_4_value = pc_plus_4;
    end


    // =========================================================
    // WRITE-BACK MUX
    //
    // 00 = ALU result
    //      ADD / ADDI / LUI / other ALU instructions
    //
    // 01 = Memory data
    //      LW
    //
    // 10 = PC + 4
    //      JAL / JALR
    //
    // 11 = default 0
    // =========================================================

    always_comb begin

        case (wb_sel)

            2'b00: begin
                write_back_data = alu_result;
            end

            2'b01: begin
                write_back_data = memory_data;
            end

            2'b10: begin
                write_back_data = pc_plus_4;
            end

            default: begin
                write_back_data = 32'd0;
            end

        endcase

    end

endmodule
