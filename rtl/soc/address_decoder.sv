`timescale 1ns/1ps

module address_decoder (

    input  logic [31:0] address,
    input  logic        mem_read,
    input  logic        mem_write,

    output logic        dmem_read,
    output logic        dmem_write,

    output logic        accel_read,
    output logic        accel_write
);

    // =========================================================
    // NOVA-1 MEMORY MAP
    // =========================================================
    //
    // 0x0000_0000 - 0x3FFF_FFFF : Normal Data Memory
    // 0x4000_0000 - 0x4000_00FF : AI Accelerator
    //
    // =========================================================

    always_comb begin

        // Defaults
        dmem_read   = 1'b0;
        dmem_write  = 1'b0;

        accel_read  = 1'b0;
        accel_write = 1'b0;


        // -----------------------------------------------------
        // AI ACCELERATOR REGION
        // -----------------------------------------------------

        if ((address >= 32'h4000_0000) &&
            (address <= 32'h4000_00FF)) begin

            accel_read  = mem_read;
            accel_write = mem_write;

        end

        // -----------------------------------------------------
        // NORMAL DATA MEMORY
        // -----------------------------------------------------

        else begin

            dmem_read  = mem_read;
            dmem_write = mem_write;

        end

    end

endmodule