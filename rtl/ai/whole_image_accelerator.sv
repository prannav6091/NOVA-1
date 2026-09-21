module whole_image_accelerator #(

    parameter integer MAX_WIDTH = 4096

)(

    input logic clk,
    input logic reset,

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    input logic signed [7:0] pixel_in,
    input logic              pixel_valid,


    // =========================================================
    // 3x3 KERNEL
    // =========================================================

    input logic signed [7:0] k00,
    input logic signed [7:0] k01,
    input logic signed [7:0] k02,

    input logic signed [7:0] k10,
    input logic signed [7:0] k11,
    input logic signed [7:0] k12,

    input logic signed [7:0] k20,
    input logic signed [7:0] k21,
    input logic signed [7:0] k22,


    // =========================================================
    // CNN POSTPROCESS CONFIGURATION
    // =========================================================

    input logic signed [31:0] bias,

    input logic [4:0] quant_shift,


    // =========================================================
    // OUTPUT
    //
    // Still 32-bit externally for current DMA compatibility.
    //
    // Internally the actual feature is INT8.
    // =========================================================

    output logic signed [31:0] feature_out,
    output logic               feature_valid

);


    // =========================================================
    // WINDOW SIGNALS
    // =========================================================

    logic signed [7:0] w00, w01, w02;

    logic signed [7:0] w10, w11, w12;

    logic signed [7:0] w20, w21, w22;

    logic window_valid;


    // =========================================================
    // CONVOLUTION SIGNALS
    // =========================================================

    logic signed [31:0] conv_result;

    logic conv_valid;


    // =========================================================
    // POSTPROCESS SIGNALS
    // =========================================================

    logic signed [7:0] quantized_feature;

    logic quantized_valid;


    // =========================================================
    // STREAMING WINDOW GENERATOR
    // =========================================================

    stream_window_3x3 #(

        .MAX_WIDTH(MAX_WIDTH)

    ) WINDOW_GENERATOR (

        .clk(clk),
        .reset(reset),

        .image_width(image_width),
        .image_height(image_height),

        .pixel_in(pixel_in),
        .pixel_valid(pixel_valid),

        .w00(w00),
        .w01(w01),
        .w02(w02),

        .w10(w10),
        .w11(w11),
        .w12(w12),

        .w20(w20),
        .w21(w21),
        .w22(w22),

        .window_valid(window_valid)

    );


    // =========================================================
    // 3x3 CONVOLUTION
    // =========================================================

    conv3x3_engine CONVOLUTION_ENGINE (

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

        .k00(k00),
        .k01(k01),
        .k02(k02),

        .k10(k10),
        .k11(k11),
        .k12(k12),

        .k20(k20),
        .k21(k21),
        .k22(k22),

        .result(conv_result),
        .result_valid(conv_valid)

    );


    // =========================================================
    // CNN POSTPROCESS
    //
    // accumulation
    //      ?
    // bias
    //      ?
    // ReLU
    //      ?
    // requantization
    //      ?
    // INT8
    // =========================================================

    cnn_postprocess POSTPROCESS (

        .accumulator(conv_result),

        .bias(bias),

        .quant_shift(quant_shift),

        .valid_in(conv_valid),

        .feature_out(quantized_feature),

        .valid_out(quantized_valid)

    );


    // =========================================================
    // CURRENT DMA COMPATIBILITY
    //
    // Store INT8 result as sign-extended 32-bit value.
    // =========================================================

    always_comb begin

        feature_out =
            {{24{quantized_feature[7]}},
             quantized_feature};

        feature_valid =
            quantized_valid;

    end


endmodule
