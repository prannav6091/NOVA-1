module multi_filter_conv_top #(
    parameter integer MAX_WIDTH   = 4096,
    parameter integer MAX_OUTPUTS = 8294400
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // IMAGE CONFIGURATION
    // =========================================================

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    input logic [15:0] input_channels,
    input logic [15:0] output_channels,


    // =========================================================
    // FILTER CONTROL
    //
    // current_filter tells us which output feature map
    // is currently being calculated.
    // =========================================================

    input logic [15:0] current_filter,
    input logic        filter_start,


    // =========================================================
    // INPUT CHANNEL CONTROL
    // =========================================================

    input logic [15:0] channel_index,
    input logic        channel_start,


    // =========================================================
    // PIXEL STREAM
    // =========================================================

    input logic signed [7:0] pixel_in,
    input logic              pixel_valid,


    // =========================================================
    // CURRENT FILTER + CHANNEL 3x3 WEIGHTS
    //
    // External weight controller will eventually provide:
    //
    // W[filter][channel][3][3]
    //
    // For now we directly provide the active 3x3 kernel.
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
    // CURRENT FILTER POSTPROCESS PARAMETERS
    //
    // Each output filter eventually has its own:
    //
    // bias[filter]
    // quant_shift[filter]
    // =========================================================

    input logic signed [31:0] bias,
    input logic [4:0]         quant_shift,


    // =========================================================
    // FEATURE OUTPUT
    // =========================================================

    output logic signed [7:0] feature_out,
    output logic              feature_valid,

    // Spatial position inside feature map
    output logic [31:0]       feature_index,

    // Which output channel/filter this belongs to
    output logic [15:0]       feature_channel
);


    // =========================================================
    // INTERNAL FEATURE STREAM
    // =========================================================

    logic signed [7:0] inner_feature;
    logic              inner_feature_valid;

    logic [31:0]       inner_feature_index;


    // =========================================================
    // FILTER TAG
    //
    // current_filter remains constant while an entire
    // filter is being evaluated.
    // =========================================================

    logic [15:0] active_filter;


    always_ff @(posedge clk) begin

        if (reset) begin

            active_filter <=
                16'd0;

        end

        else if (filter_start) begin

            active_filter <=
                current_filter;

        end

    end


    // =========================================================
    // MULTI-CHANNEL CONVOLUTION ENGINE
    //
    // One filter is processed at a time.
    // =========================================================

    multi_channel_conv_top #(

        .MAX_WIDTH(
            MAX_WIDTH
        ),

        .MAX_OUTPUTS(
            MAX_OUTPUTS
        )

    ) MULTI_CHANNEL_ENGINE (

        .clk(clk),
        .reset(reset),

        .image_width(
            image_width
        ),

        .image_height(
            image_height
        ),

        .input_channels(
            input_channels
        ),

        .channel_index(
            channel_index
        ),

        .channel_start(
            channel_start
        ),

        .pixel_in(
            pixel_in
        ),

        .pixel_valid(
            pixel_valid
        ),


        // -----------------------------------------------------
        // Current filter/current channel weights
        // -----------------------------------------------------

        .k00(k00),
        .k01(k01),
        .k02(k02),

        .k10(k10),
        .k11(k11),
        .k12(k12),

        .k20(k20),
        .k21(k21),
        .k22(k22),


        // -----------------------------------------------------
        // Per-filter postprocessing
        // -----------------------------------------------------

        .bias(
            bias
        ),

        .quant_shift(
            quant_shift
        ),


        // -----------------------------------------------------
        // Feature output
        // -----------------------------------------------------

        .feature_out(
            inner_feature
        ),

        .feature_valid(
            inner_feature_valid
        ),

        .feature_index(
            inner_feature_index
        )

    );


    // =========================================================
    // OUTPUT
    // =========================================================

    always_comb begin

        feature_out =
            inner_feature;

        feature_valid =
            inner_feature_valid;

        feature_index =
            inner_feature_index;

        feature_channel =
            active_filter;

    end


endmodule
