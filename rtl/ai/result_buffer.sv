`timescale 1ns/1ps

module result_buffer #(

    parameter DEPTH      = 36,
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 32

)(

    input logic clk,
    input logic rst,

    // Write port
    input logic                      wr_en,
    input logic [ADDR_WIDTH-1:0]     wr_addr,
    input logic signed [DATA_WIDTH-1:0] wr_data,

    // Read port
    input  logic [ADDR_WIDTH-1:0]       rd_addr,
    output logic signed [DATA_WIDTH-1:0] rd_data

);

    // =========================================================
    // RESULT MEMORY
    //
    // For 8x8 image + 3x3 convolution:
    //
    // (8-3+1) x (8-3+1)
    // = 6 x 6
    // = 36 results
    // =========================================================

    logic signed [DATA_WIDTH-1:0] memory [0:DEPTH-1];


    // =========================================================
    // WRITE
    // =========================================================

    always_ff @(posedge clk) begin

        if (wr_en) begin

            if (wr_addr < DEPTH)
                memory[wr_addr] <= wr_data;

        end

    end


    // =========================================================
    // ASYNCHRONOUS READ
    // =========================================================

    always_comb begin

        if (rd_addr < DEPTH)
            rd_data = memory[rd_addr];

        else
            rd_data = '0;

    end


endmodule
