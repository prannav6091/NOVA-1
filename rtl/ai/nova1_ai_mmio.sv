module nova1_ai_mmio #(
    parameter integer MAX_WIDTH = 4096
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // CPU / MMIO INTERFACE
    // =========================================================

    input  logic        accel_read,
    input  logic        accel_write,

    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data,


    // =========================================================
    // LEGACY PIXEL STREAM
    // =========================================================

    input logic signed [7:0] pixel_in,
    input logic              pixel_valid,


    // =========================================================
    // LEGACY FEATURE STREAM
    // =========================================================

    output logic signed [31:0] feature_out,
    output logic               feature_valid,


    // =========================================================
    // COMMON IMAGE CONFIG
    // =========================================================

    output logic [31:0] input_base_address,
    output logic [31:0] output_base_address,

    output logic [15:0] image_width,
    output logic [15:0] image_height,

    output logic dma_start,


    // =========================================================
    // LEGACY STATUS
    // =========================================================

    output logic busy,
    output logic done,


    // =========================================================
    // CNN NETWORK CONFIG
    // =========================================================

    output logic [15:0] network_num_layers,
    output logic [15:0] network_input_channels,

    output logic [31:0] network_buffer_a_base,
    output logic [31:0] network_buffer_b_base,

    output logic network_start,


    // =========================================================
    // NETWORK LAYER DESCRIPTOR PROGRAMMING
    // =========================================================

    output logic        layer_descriptor_wr_en,
    output logic [15:0] layer_descriptor_wr_index,
    output logic [15:0] layer_descriptor_wr_cout,
    output logic [1:0]  layer_descriptor_wr_stride,


    // =========================================================
    // MODEL LAYER SELECTOR
    //
    // Selects which layer receives subsequent:
    //
    // weight
    // bias
    // quant
    //
    // programming operations.
    // =========================================================

    output logic [15:0] network_weight_wr_layer,


    // =========================================================
    // NETWORK WEIGHT PROGRAMMING
    // =========================================================

    output logic        network_weight_wr_en,
    output logic [15:0] network_weight_wr_filter,
    output logic [15:0] network_weight_wr_channel,
    output logic [3:0]  network_weight_wr_tap,
    output logic signed [7:0] network_weight_wr_data,


    // =========================================================
    // NETWORK BIAS PROGRAMMING
    // =========================================================

    output logic network_bias_wr_en,

    output logic [15:0] network_bias_wr_filter,
    output logic signed [31:0] network_bias_wr_data,


    // =========================================================
    // NETWORK QUANT PROGRAMMING
    // =========================================================

    output logic network_quant_wr_en,

    output logic [15:0] network_quant_wr_filter,
    output logic [4:0]  network_quant_wr_data,


    // =========================================================
    // NETWORK STATUS INPUT
    // =========================================================

    input logic network_busy,
    input logic network_done
);


    // =========================================================
    // LEGACY MMIO MAP
    // =========================================================

    localparam logic [31:0] CONTROL_ADDR =
        32'h4000_0000;

    localparam logic [31:0] STATUS_ADDR =
        32'h4000_0004;

    localparam logic [31:0] WIDTH_ADDR =
        32'h4000_0008;

    localparam logic [31:0] HEIGHT_ADDR =
        32'h4000_000C;

    localparam logic [31:0] INPUT_BASE_ADDR =
        32'h4000_0010;

    localparam logic [31:0] OUTPUT_BASE_ADDR =
        32'h4000_0014;


    localparam logic [31:0] WEIGHTS03_ADDR =
        32'h4000_0020;

    localparam logic [31:0] WEIGHTS47_ADDR =
        32'h4000_0024;

    localparam logic [31:0] WEIGHT8_ADDR =
        32'h4000_0028;


    localparam logic [31:0] BIAS_ADDR =
        32'h4000_002C;

    localparam logic [31:0] QUANT_SHIFT_ADDR =
        32'h4000_0030;


    // =========================================================
    // NETWORK CONFIG
    // =========================================================

    localparam logic [31:0] NET_NUM_LAYERS_ADDR =
        32'h4000_0040;

    localparam logic [31:0] NET_CIN_ADDR =
        32'h4000_0044;

    localparam logic [31:0] NET_BUFFER_A_ADDR =
        32'h4000_0048;

    localparam logic [31:0] NET_BUFFER_B_ADDR =
        32'h4000_004C;


    // =========================================================
    // LAYER DESCRIPTOR PROGRAMMING
    // =========================================================

    localparam logic [31:0] LAYER_INDEX_ADDR =
        32'h4000_0050;

    localparam logic [31:0] LAYER_COUT_ADDR =
        32'h4000_0054;

    localparam logic [31:0] LAYER_STRIDE_ADDR =
        32'h4000_0058;

    localparam logic [31:0] LAYER_COMMIT_ADDR =
        32'h4000_005C;


    // =========================================================
    // NETWORK CONTROL / STATUS
    // =========================================================

    localparam logic [31:0] NET_CONTROL_ADDR =
        32'h4000_0060;

    localparam logic [31:0] NET_STATUS_ADDR =
        32'h4000_0064;


    // =========================================================
    // MODEL LAYER SELECTION
    //
    // CPU writes the model layer here before loading
    // weights / bias / quantization for that layer.
    // =========================================================

    localparam logic [31:0] MODEL_LAYER_ADDR =
        32'h4000_0068;


    // =========================================================
    // MODEL WEIGHT PROGRAMMING
    // =========================================================

    localparam logic [31:0] MODEL_WEIGHT_FILTER_ADDR =
        32'h4000_0070;

    localparam logic [31:0] MODEL_WEIGHT_CHANNEL_ADDR =
        32'h4000_0074;

    localparam logic [31:0] MODEL_WEIGHT_TAP_ADDR =
        32'h4000_0078;

    localparam logic [31:0] MODEL_WEIGHT_DATA_ADDR =
        32'h4000_007C;

    localparam logic [31:0] MODEL_WEIGHT_COMMIT_ADDR =
        32'h4000_0080;


    // =========================================================
    // MODEL BIAS PROGRAMMING
    // =========================================================

    localparam logic [31:0] MODEL_BIAS_FILTER_ADDR =
        32'h4000_0084;

    localparam logic [31:0] MODEL_BIAS_DATA_ADDR =
        32'h4000_0088;

    localparam logic [31:0] MODEL_BIAS_COMMIT_ADDR =
        32'h4000_008C;


    // =========================================================
    // MODEL QUANT PROGRAMMING
    // =========================================================

    localparam logic [31:0] MODEL_QUANT_FILTER_ADDR =
        32'h4000_0090;

    localparam logic [31:0] MODEL_QUANT_DATA_ADDR =
        32'h4000_0094;

    localparam logic [31:0] MODEL_QUANT_COMMIT_ADDR =
        32'h4000_0098;


    // =========================================================
    // LEGACY KERNEL
    // =========================================================

    logic signed [7:0] k00;
    logic signed [7:0] k01;
    logic signed [7:0] k02;

    logic signed [7:0] k10;
    logic signed [7:0] k11;
    logic signed [7:0] k12;

    logic signed [7:0] k20;
    logic signed [7:0] k21;
    logic signed [7:0] k22;


    logic signed [31:0] bias;

    logic [4:0] quant_shift;


    // =========================================================
    // LEGACY OUTPUT COUNT
    // =========================================================

    logic [31:0] expected_outputs;

    logic [31:0] output_count;


    // =========================================================
    // DESCRIPTOR STAGING
    // =========================================================

    logic [15:0] layer_program_index;

    logic [15:0] layer_program_cout;

    logic [1:0] layer_program_stride;


    // =========================================================
    // MODEL LAYER STAGING
    // =========================================================

    logic [15:0] model_layer;


    // =========================================================
    // MODEL WEIGHT STAGING
    // =========================================================

    logic [15:0] model_weight_filter;

    logic [15:0] model_weight_channel;

    logic [3:0] model_weight_tap;

    logic signed [7:0] model_weight_data;


    // =========================================================
    // MODEL BIAS STAGING
    // =========================================================

    logic [15:0] model_bias_filter;

    logic signed [31:0] model_bias_data;


    // =========================================================
    // MODEL QUANT STAGING
    // =========================================================

    logic [15:0] model_quant_filter;

    logic [4:0] model_quant_data;


    // =========================================================
    // LEGACY OUTPUT GEOMETRY
    // =========================================================

    always_comb begin

        if (
            (image_width >= 16'd3) &&
            (image_height >= 16'd3)
        ) begin

            expected_outputs =

                (image_width - 16'd2)

                *

                (image_height - 16'd2);

        end

        else begin

            expected_outputs =
                32'd0;

        end

    end


    // =========================================================
    // LEGACY WHOLE IMAGE ACCELERATOR
    // =========================================================

    whole_image_accelerator #(

        .MAX_WIDTH(
            MAX_WIDTH
        )

    ) ACCELERATOR (

        .clk(
            clk
        ),

        .reset(
            reset
        ),

        .image_width(
            image_width
        ),

        .image_height(
            image_height
        ),

        .pixel_in(
            pixel_in
        ),

        .pixel_valid(
            pixel_valid
        ),

        .k00(
            k00
        ),

        .k01(
            k01
        ),

        .k02(
            k02
        ),

        .k10(
            k10
        ),

        .k11(
            k11
        ),

        .k12(
            k12
        ),

        .k20(
            k20
        ),

        .k21(
            k21
        ),

        .k22(
            k22
        ),

        .bias(
            bias
        ),

        .quant_shift(
            quant_shift
        ),

        .feature_out(
            feature_out
        ),

        .feature_valid(
            feature_valid
        )

    );


    // =========================================================
    // WRITE / CONTROL
    // =========================================================

    always_ff @(posedge clk) begin

        // =====================================================
        // RESET
        // =====================================================

        if (reset) begin

            image_width <=
                16'd8;

            image_height <=
                16'd8;


            input_base_address <=
                32'd0;

            output_base_address <=
                32'd0;


            // =================================================
            // LEGACY IDENTITY KERNEL
            // =================================================

            k00 <=
                8'sd0;

            k01 <=
                8'sd0;

            k02 <=
                8'sd0;


            k10 <=
                8'sd0;

            k11 <=
                8'sd1;

            k12 <=
                8'sd0;


            k20 <=
                8'sd0;

            k21 <=
                8'sd0;

            k22 <=
                8'sd0;


            bias <=
                32'sd0;

            quant_shift <=
                5'd0;


            busy <=
                1'b0;

            done <=
                1'b0;

            dma_start <=
                1'b0;

            output_count <=
                32'd0;


            // =================================================
            // NETWORK CONFIG DEFAULTS
            // =================================================

            network_num_layers <=
                16'd2;

            network_input_channels <=
                16'd3;

            network_buffer_a_base <=
                32'h0000_4000;

            network_buffer_b_base <=
                32'h0000_8000;

            network_start <=
                1'b0;


            // =================================================
            // DESCRIPTOR DEFAULTS
            // =================================================

            layer_program_index <=
                16'd0;

            layer_program_cout <=
                16'd4;

            layer_program_stride <=
                2'd1;


            layer_descriptor_wr_en <=
                1'b0;

            layer_descriptor_wr_index <=
                16'd0;

            layer_descriptor_wr_cout <=
                16'd0;

            layer_descriptor_wr_stride <=
                2'd1;


            // =================================================
            // MODEL LAYER DEFAULT
            // =================================================

            model_layer <=
                16'd0;

            network_weight_wr_layer <=
                16'd0;


            // =================================================
            // MODEL WEIGHT DEFAULTS
            // =================================================

            model_weight_filter <=
                16'd0;

            model_weight_channel <=
                16'd0;

            model_weight_tap <=
                4'd0;

            model_weight_data <=
                8'sd0;


            network_weight_wr_en <=
                1'b0;

            network_weight_wr_filter <=
                16'd0;

            network_weight_wr_channel <=
                16'd0;

            network_weight_wr_tap <=
                4'd0;

            network_weight_wr_data <=
                8'sd0;


            // =================================================
            // MODEL BIAS DEFAULTS
            // =================================================

            model_bias_filter <=
                16'd0;

            model_bias_data <=
                32'sd0;


            network_bias_wr_en <=
                1'b0;

            network_bias_wr_filter <=
                16'd0;

            network_bias_wr_data <=
                32'sd0;


            // =================================================
            // MODEL QUANT DEFAULTS
            // =================================================

            model_quant_filter <=
                16'd0;

            model_quant_data <=
                5'd0;


            network_quant_wr_en <=
                1'b0;

            network_quant_wr_filter <=
                16'd0;

            network_quant_wr_data <=
                5'd0;

        end


        // =====================================================
        // NORMAL OPERATION
        // =====================================================

        else begin

            // =================================================
            // DEFAULT ONE-CYCLE PULSES
            // =================================================

            dma_start <=
                1'b0;

            network_start <=
                1'b0;

            layer_descriptor_wr_en <=
                1'b0;

            network_weight_wr_en <=
                1'b0;

            network_bias_wr_en <=
                1'b0;

            network_quant_wr_en <=
                1'b0;


            // =================================================
            // MMIO WRITES
            // =================================================

            if (accel_write) begin

                case (address)


                    // =========================================
                    // IMAGE WIDTH
                    // =========================================

                    WIDTH_ADDR: begin

                        image_width <=
                            write_data[15:0];

                    end


                    // =========================================
                    // IMAGE HEIGHT
                    // =========================================

                    HEIGHT_ADDR: begin

                        image_height <=
                            write_data[15:0];

                    end


                    // =========================================
                    // INPUT BASE
                    // =========================================

                    INPUT_BASE_ADDR: begin

                        input_base_address <=
                            write_data;

                    end


                    // =========================================
                    // LEGACY OUTPUT BASE
                    // =========================================

                    OUTPUT_BASE_ADDR: begin

                        output_base_address <=
                            write_data;

                    end


                    // =================================================
                    // LEGACY MODEL
                    // =================================================

                    WEIGHTS03_ADDR: begin

                        k00 <=
                            write_data[7:0];

                        k01 <=
                            write_data[15:8];

                        k02 <=
                            write_data[23:16];

                        k10 <=
                            write_data[31:24];

                    end


                    WEIGHTS47_ADDR: begin

                        k11 <=
                            write_data[7:0];

                        k12 <=
                            write_data[15:8];

                        k20 <=
                            write_data[23:16];

                        k21 <=
                            write_data[31:24];

                    end


                    WEIGHT8_ADDR: begin

                        k22 <=
                            write_data[7:0];

                    end


                    BIAS_ADDR: begin

                        bias <=
                            $signed(write_data);

                    end


                    QUANT_SHIFT_ADDR: begin

                        quant_shift <=
                            write_data[4:0];

                    end


                    CONTROL_ADDR: begin

                        if (
                            write_data[0] &&
                            !busy
                        ) begin

                            busy <=
                                1'b1;

                            done <=
                                1'b0;

                            output_count <=
                                32'd0;

                            dma_start <=
                                1'b1;

                        end

                    end


                    // =================================================
                    // NETWORK CONFIG
                    // =================================================

                    NET_NUM_LAYERS_ADDR: begin

                        network_num_layers <=
                            write_data[15:0];

                    end


                    NET_CIN_ADDR: begin

                        network_input_channels <=
                            write_data[15:0];

                    end


                    NET_BUFFER_A_ADDR: begin

                        network_buffer_a_base <=
                            write_data;

                    end


                    NET_BUFFER_B_ADDR: begin

                        network_buffer_b_base <=
                            write_data;

                    end


                    // =================================================
                    // DESCRIPTOR PROGRAMMING
                    // =================================================

                    LAYER_INDEX_ADDR: begin

                        layer_program_index <=
                            write_data[15:0];

                    end


                    LAYER_COUT_ADDR: begin

                        layer_program_cout <=
                            write_data[15:0];

                    end


                    LAYER_STRIDE_ADDR: begin

                        if (
                            write_data[1:0] == 2'd2
                        ) begin

                            layer_program_stride <=
                                2'd2;

                        end

                        else begin

                            layer_program_stride <=
                                2'd1;

                        end

                    end


                    LAYER_COMMIT_ADDR: begin

                        if (
                            write_data[0] &&
                            !network_busy
                        ) begin

                            layer_descriptor_wr_index <=
                                layer_program_index;

                            layer_descriptor_wr_cout <=
                                layer_program_cout;

                            layer_descriptor_wr_stride <=
                                layer_program_stride;

                            layer_descriptor_wr_en <=
                                1'b1;

                        end

                    end


                    // =================================================
                    // NETWORK START
                    // =================================================

                    NET_CONTROL_ADDR: begin

                        if (
                            write_data[0] &&
                            !network_busy
                        ) begin

                            network_start <=
                                1'b1;

                        end

                    end


                    // =================================================
                    // MODEL LAYER SELECTION
                    // =================================================

                    MODEL_LAYER_ADDR: begin

                        model_layer <=
                            write_data[15:0];

                        network_weight_wr_layer <=
                            write_data[15:0];

                    end


                    // =================================================
                    // MODEL WEIGHT STAGING
                    // =================================================

                    MODEL_WEIGHT_FILTER_ADDR: begin

                        model_weight_filter <=
                            write_data[15:0];

                    end


                    MODEL_WEIGHT_CHANNEL_ADDR: begin

                        model_weight_channel <=
                            write_data[15:0];

                    end


                    MODEL_WEIGHT_TAP_ADDR: begin

                        model_weight_tap <=
                            write_data[3:0];

                    end


                    MODEL_WEIGHT_DATA_ADDR: begin

                        model_weight_data <=
                            $signed(write_data[7:0]);

                    end


                    // =================================================
                    // COMMIT MODEL WEIGHT
                    // =================================================

                    MODEL_WEIGHT_COMMIT_ADDR: begin

                        if (
                            write_data[0] &&
                            !network_busy
                        ) begin

                            network_weight_wr_layer <=
                                model_layer;

                            network_weight_wr_filter <=
                                model_weight_filter;

                            network_weight_wr_channel <=
                                model_weight_channel;

                            network_weight_wr_tap <=
                                model_weight_tap;

                            network_weight_wr_data <=
                                model_weight_data;

                            network_weight_wr_en <=
                                1'b1;

                        end

                    end


                    // =================================================
                    // MODEL BIAS
                    // =================================================

                    MODEL_BIAS_FILTER_ADDR: begin

                        model_bias_filter <=
                            write_data[15:0];

                    end


                    MODEL_BIAS_DATA_ADDR: begin

                        model_bias_data <=
                            $signed(write_data);

                    end


                    // =================================================
                    // COMMIT MODEL BIAS
                    // =================================================

                    MODEL_BIAS_COMMIT_ADDR: begin

                        if (
                            write_data[0] &&
                            !network_busy
                        ) begin

                            network_weight_wr_layer <=
                                model_layer;

                            network_bias_wr_filter <=
                                model_bias_filter;

                            network_bias_wr_data <=
                                model_bias_data;

                            network_bias_wr_en <=
                                1'b1;

                        end

                    end


                    // =================================================
                    // MODEL QUANT
                    // =================================================

                    MODEL_QUANT_FILTER_ADDR: begin

                        model_quant_filter <=
                            write_data[15:0];

                    end


                    MODEL_QUANT_DATA_ADDR: begin

                        model_quant_data <=
                            write_data[4:0];

                    end


                    // =================================================
                    // COMMIT MODEL QUANT
                    // =================================================

                    MODEL_QUANT_COMMIT_ADDR: begin

                        if (
                            write_data[0] &&
                            !network_busy
                        ) begin

                            network_weight_wr_layer <=
                                model_layer;

                            network_quant_wr_filter <=
                                model_quant_filter;

                            network_quant_wr_data <=
                                model_quant_data;

                            network_quant_wr_en <=
                                1'b1;

                        end

                    end


                    default: begin
                    end

                endcase

            end


            // =================================================
            // LEGACY FEATURE COUNTING
            // =================================================

            if (
                busy &&
                feature_valid
            ) begin

                if (
                    (output_count + 1'b1)
                    >=
                    expected_outputs
                ) begin

                    output_count <=
                        output_count + 1'b1;

                    busy <=
                        1'b0;

                    done <=
                        1'b1;

                end

                else begin

                    output_count <=
                        output_count + 1'b1;

                end

            end

        end

    end


    // =========================================================
    // MMIO READ
    // =========================================================

    always_comb begin

        read_data =
            32'd0;


        if (accel_read) begin

            case (address)


                CONTROL_ADDR: begin

                    read_data =
                        32'd0;

                end


                STATUS_ADDR: begin

                    read_data = {
                        30'd0,
                        done,
                        busy
                    };

                end


                WIDTH_ADDR: begin

                    read_data = {
                        16'd0,
                        image_width
                    };

                end


                HEIGHT_ADDR: begin

                    read_data = {
                        16'd0,
                        image_height
                    };

                end


                INPUT_BASE_ADDR: begin

                    read_data =
                        input_base_address;

                end


                OUTPUT_BASE_ADDR: begin

                    read_data =
                        output_base_address;

                end


                WEIGHTS03_ADDR: begin

                    read_data = {
                        k10,
                        k02,
                        k01,
                        k00
                    };

                end


                WEIGHTS47_ADDR: begin

                    read_data = {
                        k21,
                        k20,
                        k12,
                        k11
                    };

                end


                WEIGHT8_ADDR: begin

                    read_data = {
                        24'd0,
                        k22
                    };

                end


                BIAS_ADDR: begin

                    read_data =
                        bias;

                end


                QUANT_SHIFT_ADDR: begin

                    read_data = {
                        27'd0,
                        quant_shift
                    };

                end


                // =================================================
                // NETWORK CONFIG READBACK
                // =================================================

                NET_NUM_LAYERS_ADDR: begin

                    read_data = {
                        16'd0,
                        network_num_layers
                    };

                end


                NET_CIN_ADDR: begin

                    read_data = {
                        16'd0,
                        network_input_channels
                    };

                end


                NET_BUFFER_A_ADDR: begin

                    read_data =
                        network_buffer_a_base;

                end


                NET_BUFFER_B_ADDR: begin

                    read_data =
                        network_buffer_b_base;

                end


                // =================================================
                // DESCRIPTOR READBACK
                // =================================================

                LAYER_INDEX_ADDR: begin

                    read_data = {
                        16'd0,
                        layer_program_index
                    };

                end


                LAYER_COUT_ADDR: begin

                    read_data = {
                        16'd0,
                        layer_program_cout
                    };

                end


                LAYER_STRIDE_ADDR: begin

                    read_data = {
                        30'd0,
                        layer_program_stride
                    };

                end


                LAYER_COMMIT_ADDR: begin

                    read_data =
                        32'd0;

                end


                // =================================================
                // NETWORK CONTROL / STATUS
                // =================================================

                NET_CONTROL_ADDR: begin

                    read_data =
                        32'd0;

                end


                NET_STATUS_ADDR: begin

                    read_data = {
                        30'd0,
                        network_done,
                        network_busy
                    };

                end


                // =================================================
                // MODEL LAYER READBACK
                // =================================================

                MODEL_LAYER_ADDR: begin

                    read_data = {
                        16'd0,
                        model_layer
                    };

                end


                // =================================================
                // MODEL WEIGHT READBACK
                // =================================================

                MODEL_WEIGHT_FILTER_ADDR: begin

                    read_data = {
                        16'd0,
                        model_weight_filter
                    };

                end


                MODEL_WEIGHT_CHANNEL_ADDR: begin

                    read_data = {
                        16'd0,
                        model_weight_channel
                    };

                end


                MODEL_WEIGHT_TAP_ADDR: begin

                    read_data = {
                        28'd0,
                        model_weight_tap
                    };

                end


                MODEL_WEIGHT_DATA_ADDR: begin

                    read_data = {
                        24'd0,
                        model_weight_data
                    };

                end


                MODEL_WEIGHT_COMMIT_ADDR: begin

                    read_data =
                        32'd0;

                end


                // =================================================
                // MODEL BIAS READBACK
                // =================================================

                MODEL_BIAS_FILTER_ADDR: begin

                    read_data = {
                        16'd0,
                        model_bias_filter
                    };

                end


                MODEL_BIAS_DATA_ADDR: begin

                    read_data =
                        model_bias_data;

                end


                MODEL_BIAS_COMMIT_ADDR: begin

                    read_data =
                        32'd0;

                end


                // =================================================
                // MODEL QUANT READBACK
                // =================================================

                MODEL_QUANT_FILTER_ADDR: begin

                    read_data = {
                        16'd0,
                        model_quant_filter
                    };

                end


                MODEL_QUANT_DATA_ADDR: begin

                    read_data = {
                        27'd0,
                        model_quant_data
                    };

                end


                MODEL_QUANT_COMMIT_ADDR: begin

                    read_data =
                        32'd0;

                end


                default: begin

                    read_data =
                        32'd0;

                end

            endcase

        end

    end


endmodule
