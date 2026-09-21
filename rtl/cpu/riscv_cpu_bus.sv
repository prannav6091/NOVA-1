`timescale 1ns/1ps

module riscv_cpu_bus (

    input logic clk,
    input logic reset,

    // =========================================================
    // EXTERNAL DATA BUS
    // =========================================================

    output logic        data_mem_read,
    output logic        data_mem_write,

    output logic [31:0] data_address,
    output logic [31:0] data_write_data,

    input  logic [31:0] data_read_data

);


    // =========================================================
    // PROGRAM COUNTER
    // =========================================================

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;


    // =========================================================
    // INSTRUCTION
    // =========================================================

    logic [31:0] instruction;


    // =========================================================
    // DECODER SIGNALS
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

    logic reg_write;
    logic alu_src;

    logic mem_read;
    logic mem_write;

    logic mem_to_reg;

    logic branch;
    logic jump;
    logic jalr;

    // NEW
    logic lui;

    logic [3:0] alu_control;


    // =========================================================
    // REGISTER FILE
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

    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;

    logic [31:0] alu_result;

    logic zero;


    // =========================================================
    // WRITEBACK
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

        .lui          (lui),

        .alu_control  (alu_control)

    );


    // =========================================================
    // REGISTER FILE
    // =========================================================

    register_file REGFILE (

        .clk         (clk),
        .reset       (reset),

        .rs1         (rs1),
        .rs2         (rs2),

        .read_data1  (read_data1),
        .read_data2  (read_data2),

        .rd          (rd),

        .write_data  (write_back_data),

        .reg_write   (reg_write)

    );


    // =========================================================
    // IMMEDIATE GENERATOR
    // =========================================================

    immediate_generator IMM_GEN (

        .instruction (instruction),

        .immediate   (immediate)

    );


    // =========================================================
    // ALU OPERAND SELECTION
    //
    // Normal:
    //      operand A = rs1
    //
    // LUI:
    //      operand A = 0
    //
    // Operand B:
    //      register or immediate
    // =========================================================

    always_comb begin

        if (lui)
            alu_operand_a = 32'd0;
        else
            alu_operand_a = read_data1;


        if (alu_src)
            alu_operand_b = immediate;
        else
            alu_operand_b = read_data2;

    end


    // =========================================================
    // ALU
    // =========================================================

    alu ALU (

        .operand_a   (alu_operand_a),

        .operand_b   (alu_operand_b),

        .alu_control (alu_control),

        .result      (alu_result),

        .zero        (zero)

    );


    // =========================================================
    // EXTERNAL DATA BUS
    // =========================================================

    assign data_address =
        alu_result;


    assign data_write_data =
        read_data2;


    assign data_mem_read =
        mem_read;


    assign data_mem_write =
        mem_write;


    // =========================================================
    // WRITEBACK SELECT
    //
    // 00 = ALU
    // 01 = memory
    // 10 = PC + 4
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
    // WRITE BACK
    // =========================================================

    write_back_logic WB (

        .alu_result       (alu_result),

        .memory_data      (data_read_data),

        .pc_plus_4        (pc_plus_4),

        .wb_sel           (wb_sel),

        .write_back_data  (write_back_data),

        .pc_plus_4_value  (pc_plus_4_value)

    );


    // =========================================================
    // BRANCH / JUMP
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

        .branch_taken     ()

    );


endmodule
