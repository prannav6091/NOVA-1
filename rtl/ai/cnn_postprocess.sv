module cnn_postprocess (

    // 32-bit convolution accumulation
    input  logic signed [31:0] accumulator,

    // One bias per output channel/filter
    input  logic signed [31:0] bias,

    // Power-of-two requantization scale
    input  logic [4:0] quant_shift,

    input  logic valid_in,

    // Quantized feature
    output logic signed [7:0] feature_out,

    output logic valid_out

);

    logic signed [31:0] biased_value;

    logic signed [31:0] relu_value;

    logic signed [7:0] quantized_value;


    // =========================================================
    // BIAS
    // =========================================================

    always_comb begin

        biased_value =
            accumulator + bias;

    end


    // =========================================================
    // ReLU
    // =========================================================

    relu RELU_STAGE (

        .data_in(biased_value),

        .valid_in(valid_in),

        .data_out(relu_value),

        .valid_out()

    );


    // =========================================================
    // REQUANTIZATION
    // =========================================================

    requantize_int8 REQUANTIZER (

        .data_in(relu_value),

        .shift_amount(quant_shift),

        .data_out(quantized_value)

    );


    // =========================================================
    // OUTPUT
    // =========================================================

    always_comb begin

        feature_out = quantized_value;

        valid_out = valid_in;

    end


endmodule
