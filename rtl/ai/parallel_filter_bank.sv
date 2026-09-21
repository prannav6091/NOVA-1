module parallel_filter_bank #(
    parameter integer FILTER_LANES = 4
)(
    input logic clk,
    input logic reset,

    input logic window_valid,

    // =========================================================
    // 3x3 WINDOW
    // =========================================================

    input logic signed [7:0] w00,
    input logic signed [7:0] w01,
    input logic signed [7:0] w02,

    input logic signed [7:0] w10,
    input logic signed [7:0] w11,
    input logic signed [7:0] w12,

    input logic signed [7:0] w20,
    input logic signed [7:0] w21,
    input logic signed [7:0] w22,

    // =========================================================
    // FILTER 0 WEIGHTS
    // =========================================================

    input logic signed [7:0] f0_k00,
    input logic signed [7:0] f0_k01,
    input logic signed [7:0] f0_k02,

    input logic signed [7:0] f0_k10,
    input logic signed [7:0] f0_k11,
    input logic signed [7:0] f0_k12,

    input logic signed [7:0] f0_k20,
    input logic signed [7:0] f0_k21,
    input logic signed [7:0] f0_k22,

    // =========================================================
    // FILTER 1 WEIGHTS
    // =========================================================

    input logic signed [7:0] f1_k00,
    input logic signed [7:0] f1_k01,
    input logic signed [7:0] f1_k02,

    input logic signed [7:0] f1_k10,
    input logic signed [7:0] f1_k11,
    input logic signed [7:0] f1_k12,

    input logic signed [7:0] f1_k20,
    input logic signed [7:0] f1_k21,
    input logic signed [7:0] f1_k22,

    // =========================================================
    // FILTER 2 WEIGHTS
    // =========================================================

    input logic signed [7:0] f2_k00,
    input logic signed [7:0] f2_k01,
    input logic signed [7:0] f2_k02,

    input logic signed [7:0] f2_k10,
    input logic signed [7:0] f2_k11,
    input logic signed [7:0] f2_k12,

    input logic signed [7:0] f2_k20,
    input logic signed [7:0] f2_k21,
    input logic signed [7:0] f2_k22,

    // =========================================================
    // FILTER 3 WEIGHTS
    // =========================================================

    input logic signed [7:0] f3_k00,
    input logic signed [7:0] f3_k01,
    input logic signed [7:0] f3_k02,

    input logic signed [7:0] f3_k10,
    input logic signed [7:0] f3_k11,
    input logic signed [7:0] f3_k12,

    input logic signed [7:0] f3_k20,
    input logic signed [7:0] f3_k21,
    input logic signed [7:0] f3_k22,

    // =========================================================
    // OUTPUTS
    // =========================================================

    output logic signed [31:0] result0,
    output logic signed [31:0] result1,
    output logic signed [31:0] result2,
    output logic signed [31:0] result3,

    output logic result_valid
);


    // =========================================================
    // FILTER 0 INTERNAL
    // =========================================================

    logic signed [31:0] result0_i;
    logic valid0;


    // =========================================================
    // FILTER 1 INTERNAL
    // =========================================================

    logic signed [31:0] result1_i;
    logic valid1;


    // =========================================================
    // FILTER 2 INTERNAL
    // =========================================================

    logic signed [31:0] result2_i;
    logic valid2;


    // =========================================================
    // FILTER 3 INTERNAL
    // =========================================================

    logic signed [31:0] result3_i;
    logic valid3;


    // =========================================================
    // FILTER 0
    // =========================================================

    conv3x3_engine FILTER0 (

        .clk(clk),
        .reset(reset),

        .window_valid(window_valid),

        .w00(w00),
        .w01(w01),
        .w02(w02),

        .w10(w10),
        .w11(w11),
        .w12(w12),

        .w20(w20),
        .w21(w21),
        .w22(w22),

        .k00(f0_k00),
        .k01(f0_k01),
        .k02(f0_k02),

        .k10(f0_k10),
        .k11(f0_k11),
        .k12(f0_k12),

        .k20(f0_k20),
        .k21(f0_k21),
        .k22(f0_k22),

        .result(result0_i),
        .result_valid(valid0)

    );


    // =========================================================
    // FILTER 1
    // =========================================================

    conv3x3_engine FILTER1 (

        .clk(clk),
        .reset(reset),

        .window_valid(window_valid),

        .w00(w00),
        .w01(w01),
        .w02(w02),

        .w10(w10),
        .w11(w11),
        .w12(w12),

        .w20(w20),
        .w21(w21),
        .w22(w22),

        .k00(f1_k00),
        .k01(f1_k01),
        .k02(f1_k02),

        .k10(f1_k10),
        .k11(f1_k11),
        .k12(f1_k12),

        .k20(f1_k20),
        .k21(f1_k21),
        .k22(f1_k22),

        .result(result1_i),
        .result_valid(valid1)

    );


    // =========================================================
    // FILTER 2
    // =========================================================

    conv3x3_engine FILTER2 (

        .clk(clk),
        .reset(reset),

        .window_valid(window_valid),

        .w00(w00),
        .w01(w01),
        .w02(w02),

        .w10(w10),
        .w11(w11),
        .w12(w12),

        .w20(w20),
        .w21(w21),
        .w22(w22),

        .k00(f2_k00),
        .k01(f2_k01),
        .k02(f2_k02),

        .k10(f2_k10),
        .k11(f2_k11),
        .k12(f2_k12),

        .k20(f2_k20),
        .k21(f2_k21),
        .k22(f2_k22),

        .result(result2_i),
        .result_valid(valid2)

    );


    // =========================================================
    // FILTER 3
    // =========================================================

    conv3x3_engine FILTER3 (

        .clk(clk),
        .reset(reset),

        .window_valid(window_valid),

        .w00(w00),
        .w01(w01),
        .w02(w02),

        .w10(w10),
        .w11(w11),
        .w12(w12),

        .w20(w20),
        .w21(w21),
        .w22(w22),

        .k00(f3_k00),
        .k01(f3_k01),
        .k02(f3_k02),

        .k10(f3_k10),
        .k11(f3_k11),
        .k12(f3_k12),

        .k20(f3_k20),
        .k21(f3_k21),
        .k22(f3_k22),

        .result(result3_i),
        .result_valid(valid3)

    );


    // =========================================================
    // OUTPUT
    // =========================================================

    always_comb begin

        result0 =
            result0_i;

        result1 =
            result1_i;

        result2 =
            result2_i;

        result3 =
            result3_i;


        // All four engines receive same window_valid and have
        // identical latency, so their valid signals should align.

        result_valid =
            valid0 &
            valid1 &
            valid2 &
            valid3;

    end


endmodule
