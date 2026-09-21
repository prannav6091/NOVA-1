module parallel_multi_channel_conv_top #(
    parameter integer MAX_WIDTH   = 4096,
    parameter integer MAX_OUTPUTS = 8294400
)(
    input logic clk,
    input logic reset,

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    input logic [15:0] input_channels,

    // NEW
    input logic [1:0] stride,

    input logic [15:0] channel_index,
    input logic        channel_start,

    input logic signed [7:0] pixel_in,
    input logic              pixel_valid,


    // =========================================================
    // FILTER 0
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
    // FILTER 1
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
    // FILTER 2
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
    // FILTER 3
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


    input logic signed [31:0] bias0,
    input logic signed [31:0] bias1,
    input logic signed [31:0] bias2,
    input logic signed [31:0] bias3,

    input logic [4:0] quant_shift0,
    input logic [4:0] quant_shift1,
    input logic [4:0] quant_shift2,
    input logic [4:0] quant_shift3,


    output logic signed [7:0] feature0,
    output logic signed [7:0] feature1,
    output logic signed [7:0] feature2,
    output logic signed [7:0] feature3,

    output logic feature_valid,

    output logic [31:0] feature_index
);


    // =========================================================
    // WINDOW
    // =========================================================

    logic signed [7:0] w00, w01, w02;
    logic signed [7:0] w10, w11, w12;
    logic signed [7:0] w20, w21, w22;

    logic window_valid;

    logic stride_window_valid;


    logic [15:0] stride_window_row;
    logic [15:0] stride_window_col;


    // =========================================================
    // OUTPUT GEOMETRY
    // =========================================================

    logic [15:0] base_output_width;
    logic [15:0] base_output_height;

    logic [31:0] outputs_per_channel;


    always_comb begin

        if (
            (image_width >= 16'd3) &&
            (image_height >= 16'd3)
        ) begin

            base_output_width =
                image_width - 16'd2;

            base_output_height =
                image_height - 16'd2;


            // =============================================
            // STRIDE 2:
            //
            // floor((W-3)/2)+1
            //
            // equivalent for valid 3x3:
            //
            // ceil((W-2)/2)
            // =============================================

            if (stride == 2'd2) begin

                outputs_per_channel =

                    (
                        (base_output_width + 1)
                        >> 1
                    )

                    *

                    (
                        (base_output_height + 1)
                        >> 1
                    );

            end

            else begin

                outputs_per_channel =

                    base_output_width
                    *
                    base_output_height;

            end

        end

        else begin

            base_output_width =
                16'd0;

            base_output_height =
                16'd0;

            outputs_per_channel =
                32'd0;

        end

    end


    // =========================================================
    // WINDOW GENERATOR
    // =========================================================

    stream_window_3x3 #(
        .MAX_WIDTH(MAX_WIDTH)
    ) WINDOW_GENERATOR (

        .clk(clk),
        .reset(reset),

        .channel_start(channel_start),

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
    // STRIDE SELECTOR
    // =========================================================

    stride_control STRIDE_CONTROL (

        .clk(clk),
        .reset(reset),

        .window_valid(window_valid),

        .channel_start(channel_start),

        .base_output_width(
            base_output_width
        ),

        .base_output_height(
            base_output_height
        ),

        .stride(stride),

        .stride_window_valid(
            stride_window_valid
        ),

        .window_row(
            stride_window_row
        ),

        .window_col(
            stride_window_col
        )

    );


    // =========================================================
    // PARALLEL CONVOLUTION
    // =========================================================

    logic signed [31:0] conv0;
    logic signed [31:0] conv1;
    logic signed [31:0] conv2;
    logic signed [31:0] conv3;

    logic conv_valid;


    parallel_filter_bank #(
        .FILTER_LANES(4)
    ) FILTER_BANK (

        .clk(clk),
        .reset(reset),

        // IMPORTANT:
        // Only accepted stride windows enter the MAC array.

        .window_valid(
            stride_window_valid
        ),

        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),

        .f0_k00(f0_k00), .f0_k01(f0_k01), .f0_k02(f0_k02),
        .f0_k10(f0_k10), .f0_k11(f0_k11), .f0_k12(f0_k12),
        .f0_k20(f0_k20), .f0_k21(f0_k21), .f0_k22(f0_k22),

        .f1_k00(f1_k00), .f1_k01(f1_k01), .f1_k02(f1_k02),
        .f1_k10(f1_k10), .f1_k11(f1_k11), .f1_k12(f1_k12),
        .f1_k20(f1_k20), .f1_k21(f1_k21), .f1_k22(f1_k22),

        .f2_k00(f2_k00), .f2_k01(f2_k01), .f2_k02(f2_k02),
        .f2_k10(f2_k10), .f2_k11(f2_k11), .f2_k12(f2_k12),
        .f2_k20(f2_k20), .f2_k21(f2_k21), .f2_k22(f2_k22),

        .f3_k00(f3_k00), .f3_k01(f3_k01), .f3_k02(f3_k02),
        .f3_k10(f3_k10), .f3_k11(f3_k11), .f3_k12(f3_k12),
        .f3_k20(f3_k20), .f3_k21(f3_k21), .f3_k22(f3_k22),

        .result0(conv0),
        .result1(conv1),
        .result2(conv2),
        .result3(conv3),

        .result_valid(conv_valid)

    );


    // =========================================================
    // METADATA
    // =========================================================

    logic [31:0] output_index_counter;
    logic [31:0] conv_output_index;

    logic [15:0] conv_channel_index;


    always_ff @(posedge clk) begin

        if (reset) begin

            output_index_counter <=
                32'd0;

            conv_output_index <=
                32'd0;

            conv_channel_index <=
                16'd0;

        end

        else begin

            if (channel_start) begin

                output_index_counter <=
                    32'd0;

            end


            if (stride_window_valid) begin

                conv_output_index <=
                    output_index_counter;

                conv_channel_index <=
                    channel_index;


                if (
                    (output_index_counter + 1)
                    >=
                    outputs_per_channel
                ) begin

                    output_index_counter <=
                        32'd0;

                end

                else begin

                    output_index_counter <=
                        output_index_counter + 1'b1;

                end

            end

        end

    end


    // =========================================================
    // FOUR CHANNEL ACCUMULATORS
    // =========================================================

    logic signed [31:0] sum0, sum1, sum2, sum3;

    logic sum_valid0;
    logic sum_valid1;
    logic sum_valid2;
    logic sum_valid3;


    channel_sum_buffer #(
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) SUM0 (
        .clk(clk),
        .reset(reset),
        .input_channels(input_channels),
        .channel_index(conv_channel_index),
        .output_index(conv_output_index),
        .channel_result(conv0),
        .channel_valid(conv_valid),
        .accumulated_result(sum0),
        .accumulated_valid(sum_valid0)
    );


    channel_sum_buffer #(
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) SUM1 (
        .clk(clk),
        .reset(reset),
        .input_channels(input_channels),
        .channel_index(conv_channel_index),
        .output_index(conv_output_index),
        .channel_result(conv1),
        .channel_valid(conv_valid),
        .accumulated_result(sum1),
        .accumulated_valid(sum_valid1)
    );


    channel_sum_buffer #(
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) SUM2 (
        .clk(clk),
        .reset(reset),
        .input_channels(input_channels),
        .channel_index(conv_channel_index),
        .output_index(conv_output_index),
        .channel_result(conv2),
        .channel_valid(conv_valid),
        .accumulated_result(sum2),
        .accumulated_valid(sum_valid2)
    );


    channel_sum_buffer #(
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) SUM3 (
        .clk(clk),
        .reset(reset),
        .input_channels(input_channels),
        .channel_index(conv_channel_index),
        .output_index(conv_output_index),
        .channel_result(conv3),
        .channel_valid(conv_valid),
        .accumulated_result(sum3),
        .accumulated_valid(sum_valid3)
    );


    // =========================================================
    // POSTPROCESS
    // =========================================================

    logic signed [7:0] q0, q1, q2, q3;

    logic qv0, qv1, qv2, qv3;


    cnn_postprocess POST0 (
        .accumulator(sum0),
        .bias(bias0),
        .quant_shift(quant_shift0),
        .valid_in(sum_valid0),
        .feature_out(q0),
        .valid_out(qv0)
    );


    cnn_postprocess POST1 (
        .accumulator(sum1),
        .bias(bias1),
        .quant_shift(quant_shift1),
        .valid_in(sum_valid1),
        .feature_out(q1),
        .valid_out(qv1)
    );


    cnn_postprocess POST2 (
        .accumulator(sum2),
        .bias(bias2),
        .quant_shift(quant_shift2),
        .valid_in(sum_valid2),
        .feature_out(q2),
        .valid_out(qv2)
    );


    cnn_postprocess POST3 (
        .accumulator(sum3),
        .bias(bias3),
        .quant_shift(quant_shift3),
        .valid_in(sum_valid3),
        .feature_out(q3),
        .valid_out(qv3)
    );


    // =========================================================
    // FINAL FEATURE INDEX
    // =========================================================

    logic [31:0] feature_counter;


    always_ff @(posedge clk) begin

        if (reset) begin

            feature_counter <=
                32'd0;

        end

        else if (
            qv0 && qv1 && qv2 && qv3
        ) begin

            if (
                (feature_counter + 1)
                >=
                outputs_per_channel
            ) begin

                feature_counter <=
                    32'd0;

            end

            else begin

                feature_counter <=
                    feature_counter + 1'b1;

            end

        end

    end


    always_comb begin

        feature0 =
            q0;

        feature1 =
            q1;

        feature2 =
            q2;

        feature3 =
            q3;


        feature_valid =
            qv0 & qv1 & qv2 & qv3;


        feature_index =
            feature_counter;

    end


endmodule
