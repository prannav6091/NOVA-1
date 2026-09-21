module cnn_network_engine #(
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
    // NETWORK CONTROL
    // =========================================================

    input logic start,
    input logic [15:0] num_layers,

    // =========================================================
    // ORIGINAL INPUT TENSOR
    // =========================================================

    input logic [15:0] original_width,
    input logic [15:0] original_height,
    input logic [15:0] original_channels,

    input logic [31:0] original_input_base,

    // =========================================================
    // PING-PONG FEATURE BUFFERS
    // =========================================================

    input logic [31:0] buffer_a_base,
    input logic [31:0] buffer_b_base,

    output logic busy,
    output logic done,

    // =========================================================
    // MEMORY
    // =========================================================

    output logic        mem_read_req,
    output logic [31:0] mem_read_address,

    input logic [31:0] mem_read_data,
    input logic        mem_read_valid,

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
    // QUANT PROGRAMMING
    // =========================================================

    input logic quant_wr_en,

    input logic [15:0] quant_wr_filter,
    input logic [4:0]  quant_wr_data,

    // =========================================================
    // DESCRIPTOR PROGRAMMING
    // =========================================================

    input logic        descriptor_wr_en,
    input logic [15:0] descriptor_wr_index,
    input logic [15:0] descriptor_wr_cout,
    input logic [1:0]  descriptor_wr_stride,

    // =========================================================
    // DEBUG
    // =========================================================

    output logic [15:0] current_layer,

    output logic [15:0] active_width,
    output logic [15:0] active_height,

    output logic [15:0] active_cin,
    output logic [15:0] active_cout,

    output logic active_layout_c4,

    output logic [1:0] active_stride,

    output logic [15:0] active_output_width,
    output logic [15:0] active_output_height,

    output logic [31:0] active_input_base,
    output logic [31:0] active_output_base
);


    // =========================================================
    // NETWORK CONTROLLER -> LAYER ENGINE
    // =========================================================

    logic network_layer_start;

    logic layer_engine_busy;
    logic layer_engine_done;

    logic [15:0] layer_width;
    logic [15:0] layer_height;

    logic [15:0] layer_input_channels;
    logic [15:0] layer_output_channels;

    logic layer_input_layout_c4;

    logic [1:0] layer_stride;

    logic [31:0] layer_input_base;
    logic [31:0] layer_output_base;

    logic [15:0] layer_output_width;
    logic [15:0] layer_output_height;


    // =========================================================
    // NETWORK CONTROLLER
    // =========================================================

    cnn_network_controller #(
        .MAX_LAYERS(
            MAX_LAYERS
        )
    ) NETWORK_CONTROLLER (

        .clk(
            clk
        ),

        .reset(
            reset
        ),

        .start(
            start
        ),

        .num_layers(
            num_layers
        ),

        .original_width(
            original_width
        ),

        .original_height(
            original_height
        ),

        .original_channels(
            original_channels
        ),

        .original_input_base(
            original_input_base
        ),

        .buffer_a_base(
            buffer_a_base
        ),

        .buffer_b_base(
            buffer_b_base
        ),

        // =====================================================
        // DESCRIPTORS
        // =====================================================

        .descriptor_wr_en(
            descriptor_wr_en
        ),

        .descriptor_wr_index(
            descriptor_wr_index
        ),

        .descriptor_wr_cout(
            descriptor_wr_cout
        ),

        .descriptor_wr_stride(
            descriptor_wr_stride
        ),

        // =====================================================
        // LAYER ENGINE HANDSHAKE
        // =====================================================

        .layer_done(
            layer_engine_done
        ),

        .layer_start(
            network_layer_start
        ),

        // =====================================================
        // CURRENT LAYER CONFIG
        // =====================================================

        .current_layer(
            current_layer
        ),

        .layer_width(
            layer_width
        ),

        .layer_height(
            layer_height
        ),

        .layer_input_channels(
            layer_input_channels
        ),

        .layer_output_channels(
            layer_output_channels
        ),

        .layer_input_layout_c4(
            layer_input_layout_c4
        ),

        .layer_stride(
            layer_stride
        ),

        .layer_input_base(
            layer_input_base
        ),

        .layer_output_base(
            layer_output_base
        ),

        .layer_output_width(
            layer_output_width
        ),

        .layer_output_height(
            layer_output_height
        ),

        .busy(
            busy
        ),

        .done(
            done
        )

    );


    // =========================================================
    // CNN LAYER ENGINE
    // =========================================================

    cnn_layer_engine #(

        .MAX_WIDTH(
            MAX_WIDTH
        ),

        .MAX_OUTPUTS(
            MAX_OUTPUTS
        ),

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
        ),

        .PIPELINE_DRAIN_CYCLES(
            PIPELINE_DRAIN_CYCLES
        )

    ) LAYER_ENGINE (

        .clk(
            clk
        ),

        .reset(
            reset
        ),

        .start(
            network_layer_start
        ),

        // =====================================================
        // EXECUTING LAYER
        //
        // Automatically controlled by network controller
        // =====================================================

        .active_layer(
            current_layer
        ),

        // =====================================================
        // GEOMETRY
        // =====================================================

        .image_width(
            layer_width
        ),

        .image_height(
            layer_height
        ),

        .input_channels(
            layer_input_channels
        ),

        .output_channels(
            layer_output_channels
        ),

        .input_layout_c4(
            layer_input_layout_c4
        ),

        .stride(
            layer_stride
        ),

        // =====================================================
        // MEMORY BASES
        // =====================================================

        .input_base_address(
            layer_input_base
        ),

        .output_base_address(
            layer_output_base
        ),

        // =====================================================
        // STATUS
        // =====================================================

        .busy(
            layer_engine_busy
        ),

        .done(
            layer_engine_done
        ),

        // =====================================================
        // MEMORY
        // =====================================================

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

        .mem_write_req(
            mem_write_req
        ),

        .mem_write_address(
            mem_write_address
        ),

        .mem_write_data(
            mem_write_data
        ),

        // =====================================================
        // PARAMETER PROGRAMMING LAYER
        //
        // Controlled independently by CPU/MMIO
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
        )

    );


    // =========================================================
    // DEBUG OUTPUTS
    // =========================================================

    always_comb begin

        active_width =
            layer_width;

        active_height =
            layer_height;

        active_cin =
            layer_input_channels;

        active_cout =
            layer_output_channels;

        active_layout_c4 =
            layer_input_layout_c4;

        active_stride =
            layer_stride;

        active_output_width =
            layer_output_width;

        active_output_height =
            layer_output_height;

        active_input_base =
            layer_input_base;

        active_output_base =
            layer_output_base;

    end


endmodule
