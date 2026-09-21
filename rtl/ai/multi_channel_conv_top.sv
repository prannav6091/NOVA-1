module multi_channel_conv_top #(
    parameter integer MAX_WIDTH   = 4096,
    parameter integer MAX_OUTPUTS = 8294400
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // IMAGE / CHANNEL CONFIG
    // =========================================================

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    input logic [15:0] input_channels,

    input logic [15:0] channel_index,
    input logic        channel_start,

    // =========================================================
    // PIXEL STREAM
    // =========================================================

    input logic signed [7:0] pixel_in,
    input logic              pixel_valid,

    // =========================================================
    // CURRENT CHANNEL KERNEL
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
    // POSTPROCESS
    // =========================================================

    input logic signed [31:0] bias,
    input logic [4:0]         quant_shift,

    // =========================================================
    // FINAL FEATURE STREAM
    // =========================================================

    output logic signed [7:0] feature_out,
    output logic              feature_valid,

    output logic [31:0]       feature_index
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

    logic signed [31:0] channel_conv_result;
    logic               channel_conv_valid;


    // =========================================================
    // METADATA PIPELINE
    //
    // These registers carry the spatial index and channel tag
    // alongside the convolution pipeline.
    // =========================================================

    logic [15:0] conv_channel_index;
    logic [31:0] conv_output_index;

    logic [31:0] output_index_counter;


    // =========================================================
    // CHANNEL ACCUMULATION
    // =========================================================

    logic signed [31:0] accumulated_result;
    logic               accumulated_valid;


    // =========================================================
    // POSTPROCESS
    // =========================================================

    logic signed [7:0] quantized_feature;
    logic              quantized_valid;


    // =========================================================
    // OUTPUT GEOMETRY
    // =========================================================

    logic [31:0] output_width;
    logic [31:0] output_height;
    logic [31:0] outputs_per_channel;


    always_comb begin

        if (
            (image_width >= 16'd3) &&
            (image_height >= 16'd3)
        ) begin

            output_width =
                image_width - 16'd2;

            output_height =
                image_height - 16'd2;

            outputs_per_channel =
                output_width *
                output_height;

        end

        else begin

            output_width =
                32'd0;

            output_height =
                32'd0;

            outputs_per_channel =
                32'd0;

        end

    end


    // =========================================================
    // STREAMING WINDOW GENERATOR
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
    // OUTPUT INDEX + CHANNEL METADATA
    //
    // IMPORTANT:
    //
    // window_valid represents one spatial convolution window.
    //
    // At that moment we capture:
    //
    //     spatial index
    //     channel number
    //
    // conv3x3_engine registers its result one stage later.
    //
    // Therefore these metadata registers are already perfectly
    // aligned with channel_conv_result/channel_conv_valid.
    //
    // DO NOT add another metadata register stage.
    // =========================================================

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

            // New channel means its spatial sequence begins at 0.

            if (channel_start) begin

                output_index_counter <=
                    32'd0;

            end


            if (window_valid) begin

                // ---------------------------------------------
                // Metadata belonging to THIS window
                // ---------------------------------------------

                conv_output_index <=
                    output_index_counter;

                conv_channel_index <=
                    channel_index;


                // ---------------------------------------------
                // Advance spatial index for next window
                // ---------------------------------------------

                if (
                    outputs_per_channel == 32'd0
                ) begin

                    output_index_counter <=
                        32'd0;

                end

                else if (
                    (output_index_counter + 1)
                    >= outputs_per_channel
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

        .result(channel_conv_result),
        .result_valid(channel_conv_valid)

    );


    // =========================================================
    // MULTI-CHANNEL ACCUMULATION
    // =========================================================

    channel_sum_buffer #(
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) CHANNEL_SUM (

        .clk(clk),
        .reset(reset),

        .input_channels(
            input_channels
        ),

        .channel_index(
            conv_channel_index
        ),

        .output_index(
            conv_output_index
        ),

        .channel_result(
            channel_conv_result
        ),

        .channel_valid(
            channel_conv_valid
        ),

        .accumulated_result(
            accumulated_result
        ),

        .accumulated_valid(
            accumulated_valid
        )

    );


    // =========================================================
    // CNN POSTPROCESS
    //
    // accumulated channels
    //          ?
    // bias
    //          ?
    // ReLU
    //          ?
    // requantization
    //          ?
    // INT8 feature
    // =========================================================

    cnn_postprocess POSTPROCESS (

        .accumulator(
            accumulated_result
        ),

        .bias(
            bias
        ),

        .quant_shift(
            quant_shift
        ),

        .valid_in(
            accumulated_valid
        ),

        .feature_out(
            quantized_feature
        ),

        .valid_out(
            quantized_valid
        )

    );


    // =========================================================
    // FINAL FEATURE OUTPUT
    // =========================================================

    always_comb begin

        feature_out =
            quantized_feature;

        feature_valid =
            quantized_valid;

    end


    // =========================================================
    // FINAL FEATURE INDEX
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            feature_index <=
                32'd0;

        end

        else if (quantized_valid) begin

            if (
                outputs_per_channel == 32'd0
            ) begin

                feature_index <=
                    32'd0;

            end

            else if (
                (feature_index + 1)
                >= outputs_per_channel
            ) begin

                feature_index <=
                    32'd0;

            end

            else begin

                feature_index <=
                    feature_index + 1'b1;

            end

        end

    end


endmodule
