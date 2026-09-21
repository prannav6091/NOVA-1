`timescale 1ns/1ps

module mac_array_4 (

    input  logic clk,
    input  logic reset,

    input  logic enable,
    input  logic clear_acc,

    // =========================================================
    // FOUR SIGNED INT8 INPUT PAIRS
    // =========================================================

    input  logic signed [7:0] a0,
    input  logic signed [7:0] b0,

    input  logic signed [7:0] a1,
    input  logic signed [7:0] b1,

    input  logic signed [7:0] a2,
    input  logic signed [7:0] b2,

    input  logic signed [7:0] a3,
    input  logic signed [7:0] b3,


    // =========================================================
    // INDIVIDUAL PRODUCTS
    // =========================================================

    output logic signed [15:0] product0,
    output logic signed [15:0] product1,
    output logic signed [15:0] product2,
    output logic signed [15:0] product3,


    // =========================================================
    // INDIVIDUAL ACCUMULATORS
    // =========================================================

    output logic signed [31:0] acc0,
    output logic signed [31:0] acc1,
    output logic signed [31:0] acc2,
    output logic signed [31:0] acc3,


    // =========================================================
    // FINAL SUM OF ALL FOUR LANES
    // =========================================================

    output logic signed [31:0] dot_product

);


    // =========================================================
    // MAC PE 0
    // =========================================================

    mac_pe MAC0 (

        .clk       (clk),
        .reset     (reset),

        .enable    (enable),
        .clear_acc (clear_acc),

        .a         (a0),
        .b         (b0),

        .product   (product0),
        .acc_out   (acc0)

    );


    // =========================================================
    // MAC PE 1
    // =========================================================

    mac_pe MAC1 (

        .clk       (clk),
        .reset     (reset),

        .enable    (enable),
        .clear_acc (clear_acc),

        .a         (a1),
        .b         (b1),

        .product   (product1),
        .acc_out   (acc1)

    );


    // =========================================================
    // MAC PE 2
    // =========================================================

    mac_pe MAC2 (

        .clk       (clk),
        .reset     (reset),

        .enable    (enable),
        .clear_acc (clear_acc),

        .a         (a2),
        .b         (b2),

        .product   (product2),
        .acc_out   (acc2)

    );


    // =========================================================
    // MAC PE 3
    // =========================================================

    mac_pe MAC3 (

        .clk       (clk),
        .reset     (reset),

        .enable    (enable),
        .clear_acc (clear_acc),

        .a         (a3),
        .b         (b3),

        .product   (product3),
        .acc_out   (acc3)

    );


    // =========================================================
    // FINAL ADDER TREE
    // =========================================================

    always_comb begin

        dot_product =
            acc0 +
            acc1 +
            acc2 +
            acc3;

    end

endmodule
