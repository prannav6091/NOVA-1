module cnn_weight_memory #(
    parameter integer MAX_INPUT_CHANNELS  = 64,
    parameter integer MAX_OUTPUT_CHANNELS = 64,
    parameter integer FILTER_LANES        = 4,
    parameter integer MAX_LAYERS          = 8
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // ACTIVE EXECUTION LAYER
    //
    // Selects which layer's parameters are READ during inference.
    // =========================================================

    input logic [15:0] active_layer,


    // =========================================================
    // PROGRAMMING LAYER
    //
    // Selects which layer's parameters are WRITTEN by CPU/MMIO.
    // =========================================================

    input logic [15:0] weight_wr_layer,


    // =========================================================
    // WEIGHT WRITE INTERFACE
    // =========================================================

    input logic weight_wr_en,

    input logic [15:0] weight_wr_filter,
    input logic [15:0] weight_wr_channel,

    // Tap index:
    //
    // 0 1 2
    // 3 4 5
    // 6 7 8

    input logic [3:0] weight_wr_tap,

    input logic signed [7:0] weight_wr_data,


    // =========================================================
    // BIAS WRITE
    // =========================================================

    input logic bias_wr_en,

    input logic [15:0] bias_wr_filter,

    input logic signed [31:0] bias_wr_data,


    // =========================================================
    // QUANTIZATION WRITE
    // =========================================================

    input logic quant_wr_en,

    input logic [15:0] quant_wr_filter,

    input logic [4:0] quant_wr_data,


    // =========================================================
    // READ SELECTION
    //
    // filter_base selects first filter of current 4-lane group.
    //
    // Example:
    //
    // filter_base = 0 -> filters 0,1,2,3
    // filter_base = 4 -> filters 4,5,6,7
    // =========================================================

    input logic [15:0] filter_base,

    input logic [15:0] channel_index,


    // =========================================================
    // FILTER 0 WEIGHTS
    // =========================================================

    output logic signed [7:0] f0_k00,
    output logic signed [7:0] f0_k01,
    output logic signed [7:0] f0_k02,

    output logic signed [7:0] f0_k10,
    output logic signed [7:0] f0_k11,
    output logic signed [7:0] f0_k12,

    output logic signed [7:0] f0_k20,
    output logic signed [7:0] f0_k21,
    output logic signed [7:0] f0_k22,


    // =========================================================
    // FILTER 1 WEIGHTS
    // =========================================================

    output logic signed [7:0] f1_k00,
    output logic signed [7:0] f1_k01,
    output logic signed [7:0] f1_k02,

    output logic signed [7:0] f1_k10,
    output logic signed [7:0] f1_k11,
    output logic signed [7:0] f1_k12,

    output logic signed [7:0] f1_k20,
    output logic signed [7:0] f1_k21,
    output logic signed [7:0] f1_k22,


    // =========================================================
    // FILTER 2 WEIGHTS
    // =========================================================

    output logic signed [7:0] f2_k00,
    output logic signed [7:0] f2_k01,
    output logic signed [7:0] f2_k02,

    output logic signed [7:0] f2_k10,
    output logic signed [7:0] f2_k11,
    output logic signed [7:0] f2_k12,

    output logic signed [7:0] f2_k20,
    output logic signed [7:0] f2_k21,
    output logic signed [7:0] f2_k22,


    // =========================================================
    // FILTER 3 WEIGHTS
    // =========================================================

    output logic signed [7:0] f3_k00,
    output logic signed [7:0] f3_k01,
    output logic signed [7:0] f3_k02,

    output logic signed [7:0] f3_k10,
    output logic signed [7:0] f3_k11,
    output logic signed [7:0] f3_k12,

    output logic signed [7:0] f3_k20,
    output logic signed [7:0] f3_k21,
    output logic signed [7:0] f3_k22,


    // =========================================================
    // PER-FILTER POSTPROCESS PARAMETERS
    // =========================================================

    output logic signed [31:0] bias0,
    output logic signed [31:0] bias1,
    output logic signed [31:0] bias2,
    output logic signed [31:0] bias3,

    output logic [4:0] quant_shift0,
    output logic [4:0] quant_shift1,
    output logic [4:0] quant_shift2,
    output logic [4:0] quant_shift3
);


    // =========================================================
    // STORAGE
    //
    // weight_mem[layer][filter][channel][tap]
    //
    // bias_mem[layer][filter]
    //
    // quant_mem[layer][filter]
    // =========================================================

    logic signed [7:0]
        weight_mem
        [0:MAX_LAYERS-1]
        [0:MAX_OUTPUT_CHANNELS-1]
        [0:MAX_INPUT_CHANNELS-1]
        [0:8];


    logic signed [31:0]
        bias_mem
        [0:MAX_LAYERS-1]
        [0:MAX_OUTPUT_CHANNELS-1];


    logic [4:0]
        quant_mem
        [0:MAX_LAYERS-1]
        [0:MAX_OUTPUT_CHANNELS-1];


    integer l;
    integer f;
    integer c;
    integer t;


    // =========================================================
    // INITIALIZATION
    // =========================================================

    initial begin

        for (
            l = 0;
            l < MAX_LAYERS;
            l = l + 1
        ) begin

            for (
                f = 0;
                f < MAX_OUTPUT_CHANNELS;
                f = f + 1
            ) begin

                bias_mem[l][f] =
                    32'sd0;

                quant_mem[l][f] =
                    5'd0;


                for (
                    c = 0;
                    c < MAX_INPUT_CHANNELS;
                    c = c + 1
                ) begin

                    for (
                        t = 0;
                        t < 9;
                        t = t + 1
                    ) begin

                        weight_mem[l][f][c][t] =
                            8'sd0;

                    end

                end

            end

        end

    end


    // =========================================================
    // WRITES
    // =========================================================

    always_ff @(posedge clk) begin

        // =====================================================
        // WEIGHT WRITE
        // =====================================================

        if (weight_wr_en) begin

            if (
                (weight_wr_layer < MAX_LAYERS) &&
                (weight_wr_filter < MAX_OUTPUT_CHANNELS) &&
                (weight_wr_channel < MAX_INPUT_CHANNELS) &&
                (weight_wr_tap < 9)
            ) begin

                weight_mem
                [weight_wr_layer]
                [weight_wr_filter]
                [weight_wr_channel]
                [weight_wr_tap]
                    <= weight_wr_data;

            end

        end


        // =====================================================
        // BIAS WRITE
        //
        // Bias uses same programming-layer selector.
        // =====================================================

        if (bias_wr_en) begin

            if (
                (weight_wr_layer < MAX_LAYERS) &&
                (bias_wr_filter < MAX_OUTPUT_CHANNELS)
            ) begin

                bias_mem
                [weight_wr_layer]
                [bias_wr_filter]
                    <= bias_wr_data;

            end

        end


        // =====================================================
        // QUANTIZATION WRITE
        //
        // Quantization uses same programming-layer selector.
        // =====================================================

        if (quant_wr_en) begin

            if (
                (weight_wr_layer < MAX_LAYERS) &&
                (quant_wr_filter < MAX_OUTPUT_CHANNELS)
            ) begin

                quant_mem
                [weight_wr_layer]
                [quant_wr_filter]
                    <= quant_wr_data;

            end

        end

    end


    // =========================================================
    // COMBINATIONAL READ
    // =========================================================

    always_comb begin

        // =====================================================
        // DEFAULT OUTPUTS
        // =====================================================

        f0_k00 = 8'sd0;
        f0_k01 = 8'sd0;
        f0_k02 = 8'sd0;

        f0_k10 = 8'sd0;
        f0_k11 = 8'sd0;
        f0_k12 = 8'sd0;

        f0_k20 = 8'sd0;
        f0_k21 = 8'sd0;
        f0_k22 = 8'sd0;


        f1_k00 = 8'sd0;
        f1_k01 = 8'sd0;
        f1_k02 = 8'sd0;

        f1_k10 = 8'sd0;
        f1_k11 = 8'sd0;
        f1_k12 = 8'sd0;

        f1_k20 = 8'sd0;
        f1_k21 = 8'sd0;
        f1_k22 = 8'sd0;


        f2_k00 = 8'sd0;
        f2_k01 = 8'sd0;
        f2_k02 = 8'sd0;

        f2_k10 = 8'sd0;
        f2_k11 = 8'sd0;
        f2_k12 = 8'sd0;

        f2_k20 = 8'sd0;
        f2_k21 = 8'sd0;
        f2_k22 = 8'sd0;


        f3_k00 = 8'sd0;
        f3_k01 = 8'sd0;
        f3_k02 = 8'sd0;

        f3_k10 = 8'sd0;
        f3_k11 = 8'sd0;
        f3_k12 = 8'sd0;

        f3_k20 = 8'sd0;
        f3_k21 = 8'sd0;
        f3_k22 = 8'sd0;


        bias0 =
            32'sd0;

        bias1 =
            32'sd0;

        bias2 =
            32'sd0;

        bias3 =
            32'sd0;


        quant_shift0 =
            5'd0;

        quant_shift1 =
            5'd0;

        quant_shift2 =
            5'd0;

        quant_shift3 =
            5'd0;


        // =====================================================
        // VALID ACTIVE LAYER
        // =====================================================

        if (
            active_layer < MAX_LAYERS
        ) begin


            // =================================================
            // LANE 0
            // =================================================

            if (
                (filter_base < MAX_OUTPUT_CHANNELS) &&
                (channel_index < MAX_INPUT_CHANNELS)
            ) begin

                f0_k00 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [0];

                f0_k01 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [1];

                f0_k02 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [2];


                f0_k10 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [3];

                f0_k11 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [4];

                f0_k12 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [5];


                f0_k20 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [6];

                f0_k21 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [7];

                f0_k22 =
                    weight_mem
                    [active_layer]
                    [filter_base]
                    [channel_index]
                    [8];


                bias0 =
                    bias_mem
                    [active_layer]
                    [filter_base];


                quant_shift0 =
                    quant_mem
                    [active_layer]
                    [filter_base];

            end


            // =================================================
            // LANE 1
            // =================================================

            if (
                ((filter_base + 1) < MAX_OUTPUT_CHANNELS) &&
                (channel_index < MAX_INPUT_CHANNELS)
            ) begin

                f1_k00 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [0];

                f1_k01 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [1];

                f1_k02 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [2];


                f1_k10 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [3];

                f1_k11 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [4];

                f1_k12 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [5];


                f1_k20 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [6];

                f1_k21 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [7];

                f1_k22 =
                    weight_mem
                    [active_layer]
                    [filter_base + 1]
                    [channel_index]
                    [8];


                bias1 =
                    bias_mem
                    [active_layer]
                    [filter_base + 1];


                quant_shift1 =
                    quant_mem
                    [active_layer]
                    [filter_base + 1];

            end


            // =================================================
            // LANE 2
            // =================================================

            if (
                ((filter_base + 2) < MAX_OUTPUT_CHANNELS) &&
                (channel_index < MAX_INPUT_CHANNELS)
            ) begin

                f2_k00 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [0];

                f2_k01 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [1];

                f2_k02 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [2];


                f2_k10 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [3];

                f2_k11 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [4];

                f2_k12 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [5];


                f2_k20 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [6];

                f2_k21 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [7];

                f2_k22 =
                    weight_mem
                    [active_layer]
                    [filter_base + 2]
                    [channel_index]
                    [8];


                bias2 =
                    bias_mem
                    [active_layer]
                    [filter_base + 2];


                quant_shift2 =
                    quant_mem
                    [active_layer]
                    [filter_base + 2];

            end


            // =================================================
            // LANE 3
            // =================================================

            if (
                ((filter_base + 3) < MAX_OUTPUT_CHANNELS) &&
                (channel_index < MAX_INPUT_CHANNELS)
            ) begin

                f3_k00 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [0];

                f3_k01 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [1];

                f3_k02 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [2];


                f3_k10 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [3];

                f3_k11 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [4];

                f3_k12 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [5];


                f3_k20 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [6];

                f3_k21 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [7];

                f3_k22 =
                    weight_mem
                    [active_layer]
                    [filter_base + 3]
                    [channel_index]
                    [8];


                bias3 =
                    bias_mem
                    [active_layer]
                    [filter_base + 3];


                quant_shift3 =
                    quant_mem
                    [active_layer]
                    [filter_base + 3];

            end

        end

    end


endmodule
