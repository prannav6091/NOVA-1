module register_file (
    input  logic        clk,
    input  logic        reset,

    // Read ports
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,

    // Write port
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    input  logic        reg_write
);

    // 32 registers, each 32 bits wide
    logic [31:0] registers [0:31];

    integer i;

    // --------------------------------
    // WRITE LOGIC
    // --------------------------------
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;

        end

        else if (reg_write && (rd != 5'd0)) begin

            // x0 cannot be written
            registers[rd] <= write_data;

        end

    end


    // --------------------------------
    // READ PORT 1
    // --------------------------------
    always_comb begin

        if (rs1 == 5'd0)
            read_data1 = 32'b0;
        else
            read_data1 = registers[rs1];

    end


    // --------------------------------
    // READ PORT 2
    // --------------------------------
    always_comb begin

        if (rs2 == 5'd0)
            read_data2 = 32'b0;
        else
            read_data2 = registers[rs2];

    end

endmodule
