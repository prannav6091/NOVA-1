module cnn_layer_engine #(
    parameter integer MAX_WIDTH             = 4096,
    parameter integer MAX_OUTPUTS           = 8294400,
    parameter integer MAX_INPUT_CHANNELS    = 64,
    parameter integer MAX_OUTPUT_CHANNELS   = 64,
    parameter integer FILTER_LANES          = 4,
    parameter integer MAX_LAYERS            = 8,
    parameter integer PIPELINE_DRAIN_CYCLES = 4
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // LAYER CONTROL
    // =========================================================

    input logic start,

    // Layer currently executing
    input logic [15:0] active_layer,

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    input logic [15:0] input_channels,
    input logic [15:0] output_channels,

    // 0 = planar
    // 1 = C4 packed
    input logic input_layout_c4,

    // 1 = stride 1
    // 2 = stride 2
    input logic [1:0] stride,

    input logic [31:0] input_base_address,
    input logic [31:0] output_base_address,

    output logic busy,
    output logic done,


    // =========================================================
    // MEMORY READ
    // =========================================================

    output logic        mem_read_req,
    output logic [31:0] mem_read_address,

    input logic [31:0] mem_read_data,
    input logic        mem_read_valid,


    // =========================================================
    // MEMORY WRITE
    // =========================================================

    output logic        mem_write_req,
    output logic [31:0] mem_write_address,
    output logic [31:0] mem_write_data,


    // =========================================================
    // MODEL PROGRAMMING LAYER
    // =========================================================

    input logic [15:0] weight_wr_layer,


    // =========================================================
    // WEIGHT PROGRAMMING
    // =========================================================

    input logic weight_wr_en,

    input logic [15:0] weight_wr_filter,
    input logic [15:0] weight_wr_channel,
    input logic [3:0]  weight_wr_tap,

    input logic signed [7:0] weight_wr_data,


    // =========================================================
    // BIAS PROGRAMMING
    // =========================================================

    input logic bias_wr_en,

    input logic [15:0] bias_wr_filter,
    input logic signed [31:0] bias_wr_data,


    // =========================================================
    // QUANTIZATION PROGRAMMING
    // =========================================================

    input logic quant_wr_en,

    input logic [15:0] quant_wr_filter,
    input logic [4:0]  quant_wr_data
);


    // =========================================================
    // LAYER CONTROLLER SIGNALS
    // =========================================================

    logic [15:0] current_channel;
    logic [15:0] filter_base;

    logic controller_channel_request;
    logic controller_filter_group_start;

    logic [FILTER_LANES-1:0] lane_active;

    logic controller_channel_done;
    logic group_compute_done;


    // =========================================================
    // DMA SIGNALS
    // =========================================================

    logic dma_busy;
    logic dma_channel_done;

    logic signed [7:0] dma_pixel;
    logic              dma_pixel_valid;

    logic [15:0] dma_channel_index;
    logic        dma_channel_start;


    // =========================================================
    // WEIGHTS
    // =========================================================

    logic signed [7:0] f0_k00, f0_k01, f0_k02;
    logic signed [7:0] f0_k10, f0_k11, f0_k12;
    logic signed [7:0] f0_k20, f0_k21, f0_k22;

    logic signed [7:0] f1_k00, f1_k01, f1_k02;
    logic signed [7:0] f1_k10, f1_k11, f1_k12;
    logic signed [7:0] f1_k20, f1_k21, f1_k22;

    logic signed [7:0] f2_k00, f2_k01, f2_k02;
    logic signed [7:0] f2_k10, f2_k11, f2_k12;
    logic signed [7:0] f2_k20, f2_k21, f2_k22;

    logic signed [7:0] f3_k00, f3_k01, f3_k02;
    logic signed [7:0] f3_k10, f3_k11, f3_k12;
    logic signed [7:0] f3_k20, f3_k21, f3_k22;


    // =========================================================
    // POSTPROCESS PARAMETERS
    // =========================================================

    logic signed [31:0] bias0;
    logic signed [31:0] bias1;
    logic signed [31:0] bias2;
    logic signed [31:0] bias3;

    logic [4:0] quant_shift0;
    logic [4:0] quant_shift1;
    logic [4:0] quant_shift2;
    logic [4:0] quant_shift3;


    // =========================================================
    // CNN OUTPUTS
    // =========================================================

    logic signed [7:0] feature0;
    logic signed [7:0] feature1;
    logic signed [7:0] feature2;
    logic signed [7:0] feature3;

    logic feature_valid;

    logic [31:0] feature_index_unused;


    // =========================================================
    // OUTPUT GEOMETRY
    // =========================================================

    logic [31:0] outputs_per_channel;

    logic [31:0] group_output_count;
    logic [31:0] group_number;


    always_comb begin

        outputs_per_channel = 32'd0;


        if (
            (image_width >= 16'd3) &&
            (image_height >= 16'd3)
        ) begin

            // =================================================
            // STRIDE 2
            //
            // out_w = floor((W - 3)/2) + 1
            // =================================================

            if (stride == 2'd2) begin

                outputs_per_channel =

                    (
                        ((image_width - 16'd2) + 1)
                        >> 1
                    )

                    *

                    (
                        ((image_height - 16'd2) + 1)
                        >> 1
                    );

            end

            // =================================================
            // STRIDE 1
            // =================================================

            else begin

                outputs_per_channel =

                    (image_width - 16'd2)
                    *
                    (image_height - 16'd2);

            end

        end


        group_number =
            filter_base / FILTER_LANES;

    end


    // =========================================================
    // LAYER CONTROLLER
    // =========================================================

    cnn_layer_controller #(
        .FILTER_LANES(
            FILTER_LANES
        )
    ) CONTROLLER (

        .clk(clk),
        .reset(reset),

        .start(start),

        .input_channels(
            input_channels
        ),

        .output_channels(
            output_channels
        ),

        .channel_done(
            controller_channel_done
        ),

        .group_compute_done(
            group_compute_done
        ),

        .current_channel(
            current_channel
        ),

        .filter_base(
            filter_base
        ),

        .channel_request(
            controller_channel_request
        ),

        .filter_group_start(
            controller_filter_group_start
        ),

        .lane_active(
            lane_active
        ),

        .busy(busy),
        .done(done)

    );


    // =========================================================
    // DUAL-LAYOUT DMA
    // =========================================================

    nova1_dma DMA (

        .clk(clk),
        .reset(reset),

        .channel_request(
            controller_channel_request
        ),

        .requested_channel(
            current_channel
        ),

        .image_width(
            image_width
        ),

        .image_height(
            image_height
        ),

        .tensor_channels(
            input_channels
        ),

        .input_layout_c4(
            input_layout_c4
        ),

        .input_base_address(
            input_base_address
        ),

        .mem_read_req(
            mem_read_req
        ),

        .mem_read_address(
            mem_read_address
        ),

        .mem_read_data(
            mem_read_data
        ),

        .mem_read_valid(
            mem_read_valid
        ),

        .pixel_out(
            dma_pixel
        ),

        .pixel_valid(
            dma_pixel_valid
        ),

        .channel_index(
            dma_channel_index
        ),

        .channel_start(
            dma_channel_start
        ),

        .busy(
            dma_busy
        ),

        .channel_done(
            dma_channel_done
        )

    );


    // =========================================================
    // PIPELINE DRAIN
    // =========================================================

    logic drain_active;

    integer drain_counter;


    always_ff @(posedge clk) begin

        if (reset) begin

            drain_active <=
                1'b0;

            drain_counter <=
                0;

            controller_channel_done <=
                1'b0;

        end

        else begin

            controller_channel_done <=
                1'b0;


            if (
                dma_channel_done &&
                !drain_active
            ) begin

                drain_active <=
                    1'b1;

                drain_counter <=
                    PIPELINE_DRAIN_CYCLES;

            end


            else if (drain_active) begin

                if (drain_counter > 0) begin

                    drain_counter <=
                        drain_counter - 1;

                end

                else begin

                    controller_channel_done <=
                        1'b1;

                    drain_active <=
                        1'b0;

                end

            end

        end

    end


    // =========================================================
    // LAYER-AWARE WEIGHT MEMORY
    // =========================================================

    cnn_weight_memory #(

        .MAX_INPUT_CHANNELS(
            MAX_INPUT_CHANNELS
        ),

        .MAX_OUTPUT_CHANNELS(
            MAX_OUTPUT_CHANNELS
        ),

        .FILTER_LANES(
            FILTER_LANES
        ),

        .MAX_LAYERS(
            MAX_LAYERS
        )

    ) WEIGHT_MEMORY (

        .clk(
            clk
        ),

        .reset(
            reset
        ),

        // =====================================================
        // ACTIVE EXECUTION LAYER
        // =====================================================

        .active_layer(
            active_layer
        ),

        // =====================================================
        // MODEL PROGRAMMING LAYER
        // =====================================================

        .weight_wr_layer(
            weight_wr_layer
        ),

        // =====================================================
        // WEIGHTS
        // =====================================================

        .weight_wr_en(
            weight_wr_en
        ),

        .weight_wr_filter(
            weight_wr_filter
        ),

        .weight_wr_channel(
            weight_wr_channel
        ),

        .weight_wr_tap(
            weight_wr_tap
        ),

        .weight_wr_data(
            weight_wr_data
        ),

        // =====================================================
        // BIAS
        // =====================================================

        .bias_wr_en(
            bias_wr_en
        ),

        .bias_wr_filter(
            bias_wr_filter
        ),

        .bias_wr_data(
            bias_wr_data
        ),

        // =====================================================
        // QUANTIZATION
        // =====================================================

        .quant_wr_en(
            quant_wr_en
        ),

        .quant_wr_filter(
            quant_wr_filter
        ),

        .quant_wr_data(
            quant_wr_data
        ),

        // =====================================================
        // READ SELECTION
        // =====================================================

        .filter_base(
            filter_base
        ),

        .channel_index(
            dma_channel_index
        ),


        // =====================================================
        // FILTER 0
        // =====================================================

        .f0_k00(f0_k00),
        .f0_k01(f0_k01),
        .f0_k02(f0_k02),

        .f0_k10(f0_k10),
        .f0_k11(f0_k11),
        .f0_k12(f0_k12),

        .f0_k20(f0_k20),
        .f0_k21(f0_k21),
        .f0_k22(f0_k22),


        // =====================================================
        // FILTER 1
        // =====================================================

        .f1_k00(f1_k00),
        .f1_k01(f1_k01),
        .f1_k02(f1_k02),

        .f1_k10(f1_k10),
        .f1_k11(f1_k11),
        .f1_k12(f1_k12),

        .f1_k20(f1_k20),
        .f1_k21(f1_k21),
        .f1_k22(f1_k22),


        // =====================================================
        // FILTER 2
        // =====================================================

        .f2_k00(f2_k00),
        .f2_k01(f2_k01),
        .f2_k02(f2_k02),

        .f2_k10(f2_k10),
        .f2_k11(f2_k11),
        .f2_k12(f2_k12),

        .f2_k20(f2_k20),
        .f2_k21(f2_k21),
        .f2_k22(f2_k22),


        // =====================================================
        // FILTER 3
        // =====================================================

        .f3_k00(f3_k00),
        .f3_k01(f3_k01),
        .f3_k02(f3_k02),

        .f3_k10(f3_k10),
        .f3_k11(f3_k11),
        .f3_k12(f3_k12),

        .f3_k20(f3_k20),
        .f3_k21(f3_k21),
        .f3_k22(f3_k22),


        // =====================================================
        // POSTPROCESS
        // =====================================================

        .bias0(
            bias0
        ),

        .bias1(
            bias1
        ),

        .bias2(
            bias2
        ),

        .bias3(
            bias3
        ),

        .quant_shift0(
            quant_shift0
        ),

        .quant_shift1(
            quant_shift1
        ),

        .quant_shift2(
            quant_shift2
        ),

        .quant_shift3(
            quant_shift3
        )

    );


    // =========================================================
    // STRIDE-AWARE PARALLEL CNN DATAPATH
    // =========================================================

    parallel_multi_channel_conv_top #(

        .MAX_WIDTH(
            MAX_WIDTH
        ),

        .MAX_OUTPUTS(
            MAX_OUTPUTS
        )

    ) CNN_DATAPATH (

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

        .stride(
            stride
        ),

        .channel_index(
            dma_channel_index
        ),

        .channel_start(
            dma_channel_start
        ),

        .pixel_in(
            dma_pixel
        ),

        .pixel_valid(
            dma_pixel_valid
        ),


        // =====================================================
        // FILTER 0
        // =====================================================

        .f0_k00(f0_k00),
        .f0_k01(f0_k01),
        .f0_k02(f0_k02),

        .f0_k10(f0_k10),
        .f0_k11(f0_k11),
        .f0_k12(f0_k12),

        .f0_k20(f0_k20),
        .f0_k21(f0_k21),
        .f0_k22(f0_k22),


        // =====================================================
        // FILTER 1
        // =====================================================

        .f1_k00(f1_k00),
        .f1_k01(f1_k01),
        .f1_k02(f1_k02),

        .f1_k10(f1_k10),
        .f1_k11(f1_k11),
        .f1_k12(f1_k12),

        .f1_k20(f1_k20),
        .f1_k21(f1_k21),
        .f1_k22(f1_k22),


        // =====================================================
        // FILTER 2
        // =====================================================

        .f2_k00(f2_k00),
        .f2_k01(f2_k01),
        .f2_k02(f2_k02),

        .f2_k10(f2_k10),
        .f2_k11(f2_k11),
        .f2_k12(f2_k12),

        .f2_k20(f2_k20),
        .f2_k21(f2_k21),
        .f2_k22(f2_k22),


        // =====================================================
        // FILTER 3
        // =====================================================

        .f3_k00(f3_k00),
        .f3_k01(f3_k01),
        .f3_k02(f3_k02),

        .f3_k10(f3_k10),
        .f3_k11(f3_k11),
        .f3_k12(f3_k12),

        .f3_k20(f3_k20),
        .f3_k21(f3_k21),
        .f3_k22(f3_k22),


        // =====================================================
        // POSTPROCESS
        // =====================================================

        .bias0(
            bias0
        ),

        .bias1(
            bias1
        ),

        .bias2(
            bias2
        ),

        .bias3(
            bias3
        ),

        .quant_shift0(
            quant_shift0
        ),

        .quant_shift1(
            quant_shift1
        ),

        .quant_shift2(
            quant_shift2
        ),

        .quant_shift3(
            quant_shift3
        ),


        // =====================================================
        // OUTPUT
        // =====================================================

        .feature0(
            feature0
        ),

        .feature1(
            feature1
        ),

        .feature2(
            feature2
        ),

        .feature3(
            feature3
        ),

        .feature_valid(
            feature_valid
        ),

        .feature_index(
            feature_index_unused
        )

    );


    // =========================================================
    // C4 FEATURE WRITEBACK
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            mem_write_req <=
                1'b0;

            mem_write_address <=
                32'd0;

            mem_write_data <=
                32'd0;

            group_output_count <=
                32'd0;

            group_compute_done <=
                1'b0;

        end

        else begin

            mem_write_req <=
                1'b0;


            // =================================================
            // NEW FILTER GROUP
            // =================================================

            if (
                controller_filter_group_start
            ) begin

                group_output_count <=
                    32'd0;

                group_compute_done <=
                    1'b0;

            end


            // =================================================
            // WRITE FEATURE
            // =================================================

            if (feature_valid) begin

                mem_write_req <=
                    1'b1;


                mem_write_address <=

                    output_base_address

                    +

                    (
                        (
                            (
                                group_number
                                *
                                outputs_per_channel
                            )
                            +
                            group_output_count
                        )
                        *
                        32'd4
                    );


                // =================================================
                // PACK FOUR INT8 LANES
                // =================================================

                if (lane_active[0])
                    mem_write_data[7:0] <=
                        feature0;
                else
                    mem_write_data[7:0] <=
                        8'd0;


                if (lane_active[1])
                    mem_write_data[15:8] <=
                        feature1;
                else
                    mem_write_data[15:8] <=
                        8'd0;


                if (lane_active[2])
                    mem_write_data[23:16] <=
                        feature2;
                else
                    mem_write_data[23:16] <=
                        8'd0;


                if (lane_active[3])
                    mem_write_data[31:24] <=
                        feature3;
                else
                    mem_write_data[31:24] <=
                        8'd0;


                // =================================================
                // LAST OUTPUT OF FILTER GROUP
                // =================================================

                if (
                    (group_output_count + 1)
                    >=
                    outputs_per_channel
                ) begin

                    group_output_count <=
                        32'd0;


                    // Sticky until next filter group begins.

                    group_compute_done <=
                        1'b1;

                end

                else begin

                    group_output_count <=
                        group_output_count + 1'b1;

                end

            end

        end

    end


endmodule
