`timescale 1ns/1ps

module data_memory #(
    parameter integer MEM_DEPTH = 16384
)(
    input logic clk,

    // =========================================================
    // CPU PORT
    // =========================================================

    input  logic        cpu_mem_read,
    input  logic        cpu_mem_write,

    input  logic [31:0] cpu_address,
    input  logic [31:0] cpu_write_data,

    output logic [31:0] cpu_read_data,


    // =========================================================
    // DMA READ PORT
    // =========================================================

    input  logic        dma_mem_read_req,
    input  logic [31:0] dma_mem_read_address,

    output logic [31:0] dma_mem_read_data,
    output logic        dma_mem_read_valid,


    // =========================================================
    // DMA WRITE PORT
    // =========================================================

    input  logic        dma_mem_write_req,
    input  logic [31:0] dma_mem_write_address,
    input  logic [31:0] dma_mem_write_data
);


    // =========================================================
    // ADDRESS WIDTH
    //
    // MEM_DEPTH = 16384 words
    //
    // log2(16384) = 14 address bits
    //
    // Since addresses are byte addresses and each word is
    // 4 bytes, bits [1:0] are discarded.
    //
    // Therefore for MEM_DEPTH=16384:
    //
    // word index = address[15:2]
    // =========================================================

    localparam integer ADDR_BITS =
        $clog2(MEM_DEPTH);


    // =========================================================
    // MEMORY
    // =========================================================

    logic [31:0] memory [0:MEM_DEPTH-1];


    integer i;


    // =========================================================
    // WORD INDEX
    // =========================================================

    logic [ADDR_BITS-1:0] cpu_word_index;
    logic [ADDR_BITS-1:0] dma_read_word_index;
    logic [ADDR_BITS-1:0] dma_write_word_index;


    assign cpu_word_index =
        cpu_address[ADDR_BITS+1:2];


    assign dma_read_word_index =
        dma_mem_read_address[ADDR_BITS+1:2];


    assign dma_write_word_index =
        dma_mem_write_address[ADDR_BITS+1:2];


    // =========================================================
    // INITIALIZE MEMORY
    // =========================================================

    initial begin

        for (
            i = 0;
            i < MEM_DEPTH;
            i = i + 1
        ) begin

            memory[i] =
                32'd0;

        end

    end


    // =========================================================
    // CPU READ
    //
    // Combinational read
    // =========================================================

    always_comb begin

        cpu_read_data =
            32'd0;


        if (cpu_mem_read) begin

            if (
                (cpu_address >> 2)
                <
                MEM_DEPTH
            ) begin

                cpu_read_data =
                    memory[
                        cpu_word_index
                    ];

            end

            else begin

                cpu_read_data =
                    32'd0;

            end

        end

    end


    // =========================================================
    // DMA READ
    //
    // Registered one-cycle response
    // =========================================================

    always_ff @(posedge clk) begin

        dma_mem_read_valid <=
            1'b0;


        if (dma_mem_read_req) begin

            if (
                (dma_mem_read_address >> 2)
                <
                MEM_DEPTH
            ) begin

                dma_mem_read_data <=
                    memory[
                        dma_read_word_index
                    ];

            end

            else begin

                dma_mem_read_data <=
                    32'd0;

            end


            dma_mem_read_valid <=
                1'b1;

        end

    end


    // =========================================================
    // CPU WRITE
    // =========================================================

    always_ff @(posedge clk) begin

        if (cpu_mem_write) begin

            if (
                (cpu_address >> 2)
                <
                MEM_DEPTH
            ) begin

                memory[
                    cpu_word_index
                ] <=
                    cpu_write_data;

            end

        end

    end


    // =========================================================
    // DMA / CNN WRITE
    // =========================================================

    always_ff @(posedge clk) begin

        if (dma_mem_write_req) begin

            if (
                (dma_mem_write_address >> 2)
                <
                MEM_DEPTH
            ) begin

                memory[
                    dma_write_word_index
                ] <=
                    dma_mem_write_data;

            end

        end

    end


endmodule
