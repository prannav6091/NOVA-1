`timescale 1ns/1ps

module riscv_cpu (

    input  logic clk,
    input  logic reset

);

    // =========================================================
    // PC SIGNALS
    // =========================================================

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;


    // =========================================================
    // INSTRUCTION MEMORY
    // =========================================================

    logic [31:0] instruction;


    // =========================================================
    // INSTRUCTION DECODER SIGNALS
    // =========================================================

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [2:0] instr_type;


    // =========================================================
    // CONTROL SIGNALS
    // =========================================================

    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;
    logic       jalr;

    logic [3:0] alu_control;


    // =========================================================
    // REGISTER FILE SIGNALS
    // =========================================================

    logic [31:0] read_data1;
    logic [31:0] read_data2;

    logic [31:0] write_back_data;


    // =========================================================
    // IMMEDIATE
    // =========================================================

    logic [31:0] immediate;


    // =========================================================
    // ALU
    // =========================================================

    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic        zero;


    // =========================================================
    // DATA MEMORY
    // =========================================================

    logic [31:0] memory_read_data;


    // =========================================================
    // WRITE-BACK
    // =========================================================

    logic [1:0] wb_sel;
    logic [31:0] pc_plus_4_value;


    // =========================================================
    // PROGRAM COUNTER
    // =========================================================

    program_counter PC (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),
        .pc      (pc)
    );


    // PC + 4
    assign pc_plus_4 = pc + 32'd4;


    // =========================================================
    // INSTRUCTION MEMORY
    // =========================================================

    instruction_memory IMEM (
        .address     (pc),
        .instruction (instruction)
    );


    // =========================================================
    // INSTRUCTION DECODER
    // =========================================================

    instruction_decoder DECODER (
        .instruction (instruction),

        .opcode      (opcode),
        .rd          (rd),
        .rs1         (rs1),
        .rs2         (rs2),
        .funct3      (funct3),
        .funct7      (funct7),
        .instr_type  (instr_type)
    );


    // =========================================================
    // CONTROL UNIT
    // =========================================================

    control_unit CONTROL (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7_bit5  (funct7[5]),

        .reg_write    (reg_write),
        .alu_src      (alu_src),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .mem_to_reg   (mem_to_reg),
        .branch       (branch),
        .jump         (jump),
        .jalr         (jalr),
        .alu_control  (alu_control)
    );


    // =========================================================
    // REGISTER FILE
    // =========================================================

    register_file REGFILE (
        .clk        (clk),
        .reset      (reset),

        .rs1        (rs1),
        .rs2        (rs2),

        .read_data1 (read_data1),
        .read_data2 (read_data2),

        .rd         (rd),
        .write_data (write_back_data),
        .reg_write  (reg_write)
    );


    // =========================================================
    // IMMEDIATE GENERATOR
    // =========================================================

    immediate_generator IMM_GEN (
        .instruction (instruction),
        .immediate   (immediate)
    );


    // =========================================================
    // ALU INPUT MUX
    // =========================================================

    always_comb begin

        if (alu_src)
            alu_operand_b = immediate;
        else
            alu_operand_b = read_data2;

    end


    // =========================================================
    // ALU
    // =========================================================

    alu ALU (
        .operand_a   (read_data1),
        .operand_b   (alu_operand_b),
        .alu_control (alu_control),

        .result      (alu_result),
        .zero        (zero)
    );


    // =========================================================
    // DATA MEMORY
    // =========================================================

    data_memory DMEM (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),

        .address    (alu_result),
        .write_data (read_data2),

        .read_data  (memory_read_data)
    );


    // =========================================================
    // WRITE-BACK SELECT
    // =========================================================

    always_comb begin

        if (jump)
            wb_sel = 2'b10;

        else if (mem_to_reg)
            wb_sel = 2'b01;

        else
            wb_sel = 2'b00;

    end


    // =========================================================
    // WRITE-BACK LOGIC
    // =========================================================

    write_back_logic WB (
        .alu_result       (alu_result),
        .memory_data      (memory_read_data),
        .pc_plus_4        (pc_plus_4),

        .wb_sel           (wb_sel),

        .write_back_data  (write_back_data)
    );


    // =========================================================
    // BRANCH / JUMP LOGIC
    // =========================================================

    branch_jump_logic BJ (
        .pc               (pc),

        .rs1_value        (read_data1),
        .rs2_value        (read_data2),

        .branch_immediate (immediate),
        .jump_immediate   (immediate),

        .funct3           (funct3),

        .branch           (branch),
        .jump             (jump),
        .jalr             (jalr),

        .next_pc          (next_pc),
        .branch_taken     (/* unused */)
    );

endmodule
