module instruction_decoder (
    input  logic [31:0] instruction,

    output logic [6:0] opcode,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [2:0] funct3,
    output logic [6:0] funct7,

    output logic [2:0] instr_type
);

    // Instruction type encoding
    localparam TYPE_R = 3'b000;
    localparam TYPE_I = 3'b001;
    localparam TYPE_S = 3'b010;
    localparam TYPE_B = 3'b011;
    localparam TYPE_U = 3'b100;
    localparam TYPE_J = 3'b101;
    localparam TYPE_UNKNOWN = 3'b111;

    always_comb begin

        // Extract standard instruction fields
        opcode = instruction[6:0];
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        funct7 = instruction[31:25];

        // Determine instruction format
        case (opcode)

            // R-type
            7'b0110011:
                instr_type = TYPE_R;

            // I-type
            7'b0010011,   // ADDI, SLTI, ANDI, ORI, XORI...
            7'b0000011,   // Loads
            7'b1100111:   // JALR
                instr_type = TYPE_I;

            // S-type
            7'b0100011:
                instr_type = TYPE_S;

            // B-type
            7'b1100011:
                instr_type = TYPE_B;

            // U-type
            7'b0110111,   // LUI
            7'b0010111:   // AUIPC
                instr_type = TYPE_U;

            // J-type
            7'b1101111:   // JAL
                instr_type = TYPE_J;

            default:
                instr_type = TYPE_UNKNOWN;

        endcase
    end

endmodule
